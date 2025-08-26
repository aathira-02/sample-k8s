package main

import (
    "fmt"
    "net/http"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, "Hello, World!")
}

func main() {
    http.HandleFunc("/", helloHandler)

    port := ":8080"
    fmt.Println("Server listening on http://localhost" + port)
    err := http.ListenAndServe(port, nil)
    if err != nil {
        fmt.Println("Error starting server:", err)
    }
}
