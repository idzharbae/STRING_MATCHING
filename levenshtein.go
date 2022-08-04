package main

import (
	"container/heap"
	"strings"
)

type LevenshteinMatcher struct {
	WordsToTest []string
}

type word struct {
	word string
	dist int
}

func NewLevenshteinMatcher(wordsToTest []string) *LevenshteinMatcher {
	cm := new(LevenshteinMatcher)
	cm.WordsToTest = wordsToTest
	return cm
}

func (cm *LevenshteinMatcher) Closest(searchWord string) string {
	bestVal := 10000
	bestWord := ""
	for _, word := range cm.WordsToTest {
		newVal := levenshteinDistance(&searchWord, &word)
		if newVal < bestVal {
			bestVal = newVal
			bestWord = word
		}
	}
	return bestWord
}

func (cm *LevenshteinMatcher) ClosestN(searchWord string, N int) []string {
	searchWord = strings.ToLower(searchWord)
	pq := make(PriorityQueue, 0)
	heap.Init(&pq)

	for _, word := range cm.WordsToTest {
		currentWord := strings.ToLower(word)
		currentDist := levenshteinDistance(&searchWord, &currentWord)

		if len(pq) < N {
			heap.Push(&pq, &Item{
				value:    currentWord,
				priority: currentDist,
			})

			continue
		}

		heap.Push(&pq, &Item{
			value:    currentWord,
			priority: currentDist,
		})

		heap.Pop(&pq)
	}

	result := make([]string, 0, N)
	for len(pq) > 0 {
		top := heap.Pop(&pq)
		result = append([]string{top.(*Item).value}, result...)
	}

	return result
}

// LevenshteinDistance
// from https://groups.google.com/forum/#!topic/golang-nuts/YyH1f_qCZVc
// (no min, compute lengths once, pointers, 2 rows array)
// fastest profiled
func levenshteinDistance(a, b *string) int {
	la := len(*a)
	lb := len(*b)
	d := make([]int, la+1)
	var lastdiag, olddiag, temp int

	for i := 1; i <= la; i++ {
		d[i] = i
	}
	for i := 1; i <= lb; i++ {
		d[0] = i
		lastdiag = i - 1
		for j := 1; j <= la; j++ {
			olddiag = d[j]
			min := d[j] + 1
			if (d[j-1] + 1) < min {
				min = d[j-1] + 1
			}
			if (*a)[j-1] == (*b)[i-1] {
				temp = 0
			} else {
				temp = 1
			}
			if (lastdiag + temp) < min {
				min = lastdiag + temp
			}
			d[j] = min
			lastdiag = olddiag
		}
	}
	return d[la]
}
