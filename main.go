package main

import (
    "fmt"
    "net/http"
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    fmt.Fprintln(w, "OK")
}

func main() {
    http.HandleFunc("/health", healthHandler)
    fmt.Println("Starting server on port 8080...")
    http.ListenAndServe(":8080", nil)
}