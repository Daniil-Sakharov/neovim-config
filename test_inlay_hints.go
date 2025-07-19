package main

import "fmt"

func main() {
	// Этот код должен показывать inlay hints для типов переменных
	name := "Golang Developer"
	age := 30
	isActive := true
	
	// Функция с параметрами - должны показываться имена параметров
	result := calculateSum(10, 20)
	
	// Структуры - должны показываться типы полей
	user := struct {
		Name string
		Age  int
	}{
		Name: name,
		Age:  age,
	}
	
	fmt.Printf("Hello %s, age %d, active: %v\n", user.Name, user.Age, isActive)
	fmt.Printf("Sum result: %d\n", result)
	
	// Slice с типами
	numbers := []int{1, 2, 3, 4, 5}
	for index, value := range numbers {
		fmt.Printf("Index: %d, Value: %d\n", index, value)
	}
}

func calculateSum(a, b int) int {
	return a + b
}

func processData() (string, int, error) {
	return "success", 100, nil
}