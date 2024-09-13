package main

import (
	"fmt"
	"net/http"
)

func hello(w http.ResponseWriter, req *http.Request) {

	if req.Method != "GET" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	if name := req.FormValue("name"); name != "" {
		fmt.Fprintf(w, "hello %s\n", name)
	} else {
		fmt.Fprintf(w, "hello world\n")
	}

}

func main() {
	http.HandleFunc("/hello", hello)

	http.ListenAndServe(":8090", nil)
}
