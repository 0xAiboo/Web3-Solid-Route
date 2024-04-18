package main

import (
	"fmt"
)

func main() {
	bc := NewBlockchain()

	bc.AddBlock("transfer 1U to Aiboo")
	bc.AddBlock("transfer 1U to Aiboo")
	bc.AddBlock("transfer 1U to Aiboo")
	bc.AddBlock("transfer 3U to JJ")

	for _, block := range bc.blocks {
		fmt.Printf("Prev. hash: %x\n", block.PrevBlockHash)
		fmt.Printf("Data: %s\n", block.Data)
		fmt.Printf("Hash: %x\n", block.Hash)
		fmt.Println()
	}
}
