package main

import (
  "fmt"
  "syscall"
  "net"
  "strconv"
  "io"
  "encoding/binary"
  "time"
  "errors"
  "unsafe"
)

var ServerReadyBarrier = make(chan int)

var nativeByteOrder binary.ByteOrder

func init() {
  var x uint16 = 0x0102
  var lowerByte = *(*byte)(unsafe.Pointer(&x))
  switch lowerByte {
  case 0x01:
    nativeByteOrder = binary.BigEndian
  case 0x02:
    nativeByteOrder = binary.LittleEndian
  default:
    panic("Could not determine native byte order.")
  }
}

// Write human readable response
func echo(conn io.WriteCloser, echo []byte) {
  _, _ = conn.Write(echo)
  _ = conn.Close()
}

func ntohs(n16 uint16) uint16 {
  if nativeByteOrder == binary.BigEndian {
    return n16
  }
  return (n16&0xff00)>>8 | (n16&0xff)<<8
}

func GetOriginalDestination(conn net.Conn) (daddr net.IP, dport uint16, err error) {
  tcp, ok := conn.(*net.TCPConn)
  if !ok {
    err = errors.New("socket is not tcp")
    return
  }
  file, err := tcp.File()
  if err != nil {
    return
  }
  defer file.Close()
  fd := file.Fd()

  // Detect underlying ip is v4 or v6
  ip := conn.RemoteAddr().(*net.TCPAddr).IP
  isIpv4 := false
  if ip.To4() != nil {
    isIpv4 = true
  } else if ip.To16() != nil {
    isIpv4 = false
  } else {
    err = fmt.Errorf("neither ipv6 nor ipv4 original addr: %s", ip)
    return
  }

  // golang doesn't provide a struct sockaddr_storage
  // IPv6MTUInfo is chosen because
  // 1. it is no smaller than sockaddr_storage,
  // 2. it is provide the port field value
  var addr *syscall.IPv6MTUInfo
  if isIpv4 {
    addr, err =
      syscall.GetsockoptIPv6MTUInfo(
        int(fd),
        syscall.IPPROTO_IP,
        80)
    if err != nil {
      fmt.Println("error ipv4 getsockopt")
      return
    }
    // See struct sockaddr_in
    daddr = net.IPv4(
      addr.Addr.Addr[0], addr.Addr.Addr[1], addr.Addr.Addr[2], addr.Addr.Addr[3])
  } else {
    addr, err = syscall.GetsockoptIPv6MTUInfo(
      int(fd), syscall.IPPROTO_IPV6,
      80)

    if err != nil {
      fmt.Println("error ipv6 getsockopt")
      return
    }
    // See struct sockaddr_in6
    daddr = addr.Addr.Addr[:]
  }
  // See sockaddr_in6 and sockaddr_in
  dport = ntohs(addr.Addr.Port)

  fmt.Printf("GetOriginalDestination: local addr %s\n", conn.LocalAddr())
  fmt.Printf("GetOriginalDestination: original addr %s:%d\n", ip, dport)
  return
}


func restoreOriginalAddress(l net.Listener, c chan<- int) {
  defer l.Close()
  for {
    conn, err := l.Accept()
    if err != nil {
      fmt.Println("Error accepting: ", err.Error())
      continue
    }
    _, port, err := GetOriginalDestination(conn)
    if err != nil {
      fmt.Println("Error getting original dst: " + err.Error())
      conn.Close()
      continue
    }

    // echo original port for debugging.
    // Since the write amount is small it should fit in sock buffer and never blocks.
    echo(conn, []byte(strconv.Itoa(int(port))))
    // Handle connections
    // Since the write amount is small it should fit in sock buffer and never blocks.
    if port != 15002 {
      // This could be probe request from no where
      continue
    }
    // Server recovers the magical original port
    fmt.Printf("restoreOriginalAddress on: %s\n", l.Addr())
    c <- 0
    return
  }

}

func serverRun() error {
  serverAddr := [2]string{"127.0.0.1:15006", "127.0.0.1:15001"}
  c := make(chan int, 2)
  hasAtLeastOneListener := false

  for _, addr := range serverAddr {
    fmt.Println("serverRun: Listening on " + addr)
    l, err := net.Listen("tcp", addr)
    if err != nil {
      fmt.Println("Error on listening:", err.Error())
      continue
    }
    hasAtLeastOneListener = true
    go restoreOriginalAddress(l, c)
  }

  if hasAtLeastOneListener {
    ServerReadyBarrier <- 0
    // bump at least one since we currently support either v4 or v6
    <-c
    return nil
  }
  return fmt.Errorf("no listener available")
}

func clientRun() error {
  laddr, err := net.ResolveTCPAddr("tcp", "127.0.0.1:0")
  if err != nil {
    return err
  }
  serverOriginalAddress := "127.0.0.6:15002"
  raddr, err := net.ResolveTCPAddr("tcp", serverOriginalAddress)
  if err != nil {
    return err
  }
  fmt.Printf("clientRun: Dial from %s to %s\n", laddr, raddr)
  conn, err := net.DialTCP("tcp", laddr, raddr)
  if err != nil {
    fmt.Printf("Error connecting to %s: %s\n", serverOriginalAddress, err.Error())
    return err
  }
  conn.Close()
  return nil
}

func main() {
  sError := make(chan error, 1)
  sTimer := time.NewTimer(300 * time.Second)
  defer sTimer.Stop()
  go func() {
    sError <- serverRun()
  }()

  // infinite loop
  go func() {
    <-ServerReadyBarrier
    for {
      _ = clientRun()
      time.Sleep(time.Second)
    }
  }()
  select {
  case <-sTimer.C:
    fmt.Println("validation timeout")
  case err := <-sError:
    if err == nil {
      fmt.Println("validation passed")
    } else {
      fmt.Println("validation failed:" + err.Error())
    }
  }
}
