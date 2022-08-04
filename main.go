package main

import (
	"bufio"
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/go-sql-driver/mysql"
)

var db *sql.DB

type Suburb struct {
	ID         int
	SuburbName string
	CityName   string
}

func main() {
	cfg := mysql.Config{
		User:                 "user",
		Passwd:               "password",
		Net:                  "tcp",
		Addr:                 "127.0.0.1:3306",
		DBName:               "shipper",
		AllowNativePasswords: true,
	}
	// Get a database handle.
	var err error
	db, err = sql.Open("mysql", cfg.FormatDSN())
	if err != nil {
		log.Fatal(err)
	}

	rows, err := db.Query("SELECT suburb_id, city_name, suburb_name FROM suburb LEFT JOIN city ON suburb.city_id = city.city_id;")
	if err != nil {
		log.Fatal(err)
	}

	var suburbNames []string

	cnt := make(map[string]int)

	for rows.Next() {
		var result Suburb
		err = rows.Scan(&result.ID, &result.CityName, &result.SuburbName)
		if err != nil {
			log.Fatal(err)
		}

		suburbNames = append(suburbNames, result.CityName+" "+result.SuburbName)
		if _, ok := cnt[result.CityName+" "+result.SuburbName]; ok {
			cnt[result.CityName+" "+result.SuburbName] += 1
			fmt.Println(result.CityName + " " + result.SuburbName)
		} else {
			cnt[result.CityName+" "+result.SuburbName] = 1
		}
	}

	cm := NewLevenshteinMatcher(suburbNames)

	reader := bufio.NewReader(os.Stdin)
	fmt.Printf("Search city suburb: ")
	text, _ := reader.ReadString('\n')
	// text := "tabanan baturit"

	now := time.Now()
	matches := cm.ClosestN(text, 3)

	for _, match := range matches {
		fmt.Println(match)
	}

	fmt.Println("Time elapsed:", time.Since(now))
}
