package main

import (
	"bufio"
	"database/sql"
	"fmt"
	"log"
	"os"
	"regexp"
	"strings"
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
	re, err := regexp.Compile(`[^\w ]`)
	if err != nil {
		log.Fatal(err)
	}

	cfg := mysql.Config{
		User:                 "user",
		Passwd:               "password",
		Net:                  "tcp",
		Addr:                 "127.0.0.1:3306",
		DBName:               "shipper",
		AllowNativePasswords: true,
	}
	db, err = sql.Open("mysql", cfg.FormatDSN())
	if err != nil {
		log.Fatal(err)
	}

	reader := bufio.NewReader(os.Stdin)
	fmt.Printf("Search city suburb: ")
	text, _ := reader.ReadString('\n')
	// text := "tabanan baturit"

	now := time.Now()

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

		citySuburb := result.CityName + " " + result.SuburbName
		citySuburb = strings.ToLower(citySuburb)
		citySuburb = re.ReplaceAllString(citySuburb, "")
		suburbNames = append(suburbNames, citySuburb)
		if _, ok := cnt[citySuburb]; ok {
			cnt[citySuburb] += 1
			fmt.Println(citySuburb)
		} else {
			cnt[citySuburb] = 1
		}
	}

	cm := NewLevenshteinMatcher(suburbNames)

	matches := cm.ClosestN(text, 3)

	for _, match := range matches {
		fmt.Println(match.value, match.score)
	}

	fmt.Println("Time elapsed:", time.Since(now))
}
