# PriorityQueue.gd
extends Node

class_name PriorityQueue

var elements = []

func push(priority: int, item):
	elements.append([priority, item])
	_up_heapify(elements.size() - 1)

func pop():
	if elements.is_empty():
		return null
	if elements.size() == 1:
		return elements.pop_back()[1]
	var item = elements[0][1]
	elements[0] = elements.pop_back()
	_down_heapify(0)
	return item

func empty() -> bool:
	return elements.size() == 0

func _up_heapify(index: int):
	while index > 0:
		var parent = (index - 1) / 2  # Ensure proper integer division
		if elements[index][0] >= elements[parent][0]:
			break
		# Swap elements
		var temp = elements[index]
		elements[index] = elements[parent]
		elements[parent] = temp
		index = parent

func _down_heapify(index: int):
	var size = elements.size()
	while true:
		var left = 2 * index + 1
		var right = 2 * index + 2
		var smallest = index

		if left < size and elements[left][0] < elements[smallest][0]:
			smallest = left
		if right < size and elements[right][0] < elements[smallest][0]:
			smallest = right
		if smallest == index:
			break
		# Swap elements
		var temp = elements[index]
		elements[index] = elements[smallest]
		elements[smallest] = temp
		index = smallest
