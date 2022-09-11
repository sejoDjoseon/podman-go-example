package main

import (
	"fmt"
	"net/http"
	"os"
)

func handler(w http.ResponseWriter, r *http.Request) {
	var name, _ = os.Hostname()
	result := add(1, 2)

	fmt.Fprintf(w, "<h1>This request was processed by host: %s</h1>\n", name)
	fmt.Fprintf(w, "<p>the result is: %d</p>\n", result)
}

func main() {
	fmt.Fprintf(os.Stdout, "Web Server started. Listening on 0.0.0.0:80\n")
	http.HandleFunc("/", handler)
	http.ListenAndServe(":80", nil)
}

func add(a int, b int) int {
	return a + b
}
