// Inspired by: https://github.com/armhold/restic-fda/blob/master/restic-fda.go
// Also see:
// 	https://github.com/restic/restic/issues/2051#issuecomment-440477438
// 	https://n8henrie.com/2018/11/how-to-give-full-disk-access-to-a-binary-in-macos-mojave/

// restic-wrapper provides a binary to run my restic backup script in MacOS with Full Disk Access
package main

import (
	"log"
	"os"
	"os/exec"
)

func main() {
	cmd := exec.Command("/Users/lildude/.local/bin/restic-backup.sh")
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		log.Fatal(err)
	}
}
