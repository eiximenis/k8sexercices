package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", VexamenServer)
	http.ListenAndServe(":8080", nil)
}

func VexamenServer(w http.ResponseWriter, r *http.Request) {
	version := os.Getenv("VEXAMEN_VERSION")
	fmt.Fprintf(w, "Hello! This is the Vexamen server. Current version is %s ", version)
}
