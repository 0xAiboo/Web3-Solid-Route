package main

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"math/big"
	"strconv"
	"time"
)

func randomPow() string {
	time.Now().UnixNano()
	num, _ := rand.Int(rand.Reader, big.NewInt(99999999999999999))
	a := int(num.Int64())
	return strconv.Itoa(a)
}
func pow(number int, start time.Time) {
	// [:4]
	cryptoByte := sha256.Sum256([]byte("Aiboo" + randomPow()))
	cryptoStr := hex.EncodeToString(cryptoByte[:])
	strZero := ""
	for i := 0; i < number; i++ {
		strZero += "0"
	}
	if len(cryptoStr) >= number && cryptoStr[:number] == strZero {
		end := time.Now()

		fmt.Printf("%d个0达标字符串%s,查找使用时间:%vs,nonce:%d:\n", number, cryptoStr, end.Sub(start).Seconds(), randomPow())
		return
	} else {
		pow(number, start)
	}
}
func main() {
	start := time.Now()
	pow(4, start)
	start = time.Now()
	pow(5, start)

}
