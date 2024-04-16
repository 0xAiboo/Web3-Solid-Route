package main

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"math/big"
	"os"
	"strconv"
	"time"
)

func savePrivateKey(key *rsa.PrivateKey) {
	file, err := os.Create("private.pem")
	if err != nil {
		fmt.Println("无法创建私钥文件：", err)
		return
	}
	defer file.Close()
	block := &pem.Block{
		Type:  "PRIVATE KEY",
		Bytes: x509.MarshalPKCS1PrivateKey(key),
	}
	err = pem.Encode(file, block)
	if err != nil {
		fmt.Println("无法编码私钥：", err)
	}
}

func savePublicKey(key *rsa.PublicKey) {
	file, err := os.Create("public.pem")
	if err != nil {
		fmt.Println("无法创建公钥文件：", err)
		return
	}
	defer file.Close()
	bytes, err := x509.MarshalPKIXPublicKey(key)
	if err != nil {
		fmt.Println("无法序列化公钥：", err)
		return
	}
	block := &pem.Block{
		Type:  "PUBLIC KEY",
		Bytes: bytes,
	}

	err = pem.Encode(file, block)
	if err != nil {
		fmt.Println("无法编码公钥：", err)
	}
}
func RSA_Encrypt(plainText []byte, path string) []byte {
	//打开文件
	file, err := os.Open(path)
	if err != nil {
		panic(err)
	}
	defer file.Close()
	//读取文件的内容
	info, _ := file.Stat()
	buf := make([]byte, info.Size())
	file.Read(buf)
	//pem解码
	block, _ := pem.Decode(buf)
	//x509解码

	publicKeyInterface, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		panic(err)
	}
	//类型断言
	publicKey := publicKeyInterface.(*rsa.PublicKey)
	//对明文进行加密
	cipherText, err := rsa.EncryptPKCS1v15(rand.Reader, publicKey, plainText)
	if err != nil {
		panic(err)
	}
	//返回密文
	return cipherText
}

// RSA解密
// cipherText 需要解密的byte数据
// path 私钥文件路径
func RSA_Decrypt(cipherText []byte, path string) []byte {
	//打开文件
	file, err := os.Open(path)
	if err != nil {
		panic(err)
	}
	defer file.Close()
	//获取文件内容
	info, _ := file.Stat()
	buf := make([]byte, info.Size())
	file.Read(buf)
	//pem解码
	block, _ := pem.Decode(buf)
	//X509解码
	privateKey, err := x509.ParsePKCS1PrivateKey(block.Bytes)
	if err != nil {
		panic(err)
	}
	//对密文进行解密
	plainText, _ := rsa.DecryptPKCS1v15(rand.Reader, privateKey, cipherText)
	//返回明文
	return plainText
}
func day1_2(str string) {
	bitSize := 2048 // RSA位数
	privateKey, err := rsa.GenerateKey(rand.Reader, bitSize)
	if err != nil {
		fmt.Println("无法生成RSA私钥：", err)
		return
	}
	publicKey := &privateKey.PublicKey
	savePrivateKey(privateKey)
	savePublicKey(publicKey)
	data := []byte(str)
	encrypt := RSA_Encrypt(data, "public.pem")
	fmt.Println("-----------加密--------------")
	fmt.Println(string(encrypt))

	// 解密
	decrypt := RSA_Decrypt(encrypt, "private.pem")
	fmt.Println("-----------解密--------------")
	fmt.Println(string(decrypt))
}
func randomPow() string {
	time.Now().UnixNano()
	num, _ := rand.Int(rand.Reader, big.NewInt(99999999999999999))
	a := int(num.Int64())
	return strconv.Itoa(a)
}
func pow(number int, start time.Time) string {
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
		return cryptoStr
	} else {
		return pow(number, start)

	}
}
func main() {
	start := time.Now()
	powStr := pow(4, start)
	start = time.Now()
	pow(5, start)
	day1_2(powStr)
}
