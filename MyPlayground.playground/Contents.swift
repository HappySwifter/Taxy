//: Playground - noun: a place where people can play

import Cocoa
import Foundation

var str = "Hello, playground"

func adderInt(x: Int, _ y: Int) -> Int {
    return x + y
}

let summ = adderInt(1, 3)

let numbers = [1, 2, 3]

let firstNumber = numbers[0]

var numbersAgain = Array<AnyObject>()
numbersAgain.append("j")
numbersAgain.append(2)
numbersAgain.append(3)

let firstNumberAgain = numbersAgain[0]

let countryCodes = ["Austria": "AT", "United States of America": "US", "Turkey": "TR"]

let at = countryCodes["Austria"]


let optionalName = Optional<String>.Some("John")

if let name = optionalName {
    print(name)
}


func pairsFromDictionary<KeyType, ValueType>(dictionary: [KeyType: ValueType]) -> [(KeyType, ValueType)] {
    return Array(dictionary)
}

func e<T>(param: T) -> T {
    return param
}

let pairs = pairsFromDictionary(["minimum": 199, "maximum": 299])
let morePairs = pairsFromDictionary([1: "Swift", 2: "Generics", 3: "Rule"])

print(pairs)

struct Queue<Element: Equatable> {
    
    private var elements = [Element]()

    mutating func enqueue(newElement: Element) {
        elements.append(newElement)
    }
    
    mutating func dequeue() -> Element? {
        guard !elements.isEmpty else {
            return nil
        }
        return elements.removeAtIndex(0)
    }
    
    mutating func homogeneous() -> Bool {
        if let first = elements.first {
            return !elements.contains { $0 != first }
        }
        return true
    }
}


var q = Queue<Int>()

q.enqueue(4)
q.enqueue(2)


q.dequeue()
q.dequeue()
q.dequeue()
q.dequeue()





func mid<T where T: Comparable>(array: [T]) -> T {
    return array.sort()[(array.count - 1) / 2]
}


mid([3, 5, 1, 2, 4]) // 3

protocol Summable {
    func +(lhs: Self, rhs: Self) -> Self
}

extension Int: Summable {}
extension Double: Summable {}
extension String: Summable {}

func adder<T: Summable>(x: T, _ y: T) -> T {
    return x + y
}

let adderIntSum = adder(1, 2)
let adderDoubleSum = adder(1.0, 2.0)

let adderString = adder("Generics", " are Awesome!!! :]")


extension Queue {
    func peek() -> Element? {
        return elements.first
    }
}


q.enqueue(5)
q.enqueue(5)
q.homogeneous()
q.dequeue()
q.dequeue()
q.peek()









enum RideType {
    case Family
    case Kids
    case Thrill
    case Scary
    case Relaxing
    case Water
}

struct Ride {
    let name: String
    let types: Set<RideType>
    let waitTime: Double
}

let parkRides = [
    Ride(name: "Raging Rapids", types: [.Family, .Thrill, .Water], waitTime: 45.0),
    Ride(name: "Crazy Funhouse", types: [.Family], waitTime: 10.0),
    Ride(name: "Spinning Tea Cups", types: [.Kids], waitTime: 15.0),
    Ride(name: "Spooky Hollow", types: [.Scary], waitTime: 30.0),
    Ride(name: "Thunder Coaster", types: [.Family, .Thrill], waitTime: 60.0),
    Ride(name: "Grand Carousel", types: [.Family, .Kids], waitTime: 15.0),
    Ride(name: "Bumper Boats", types: [.Family, .Water], waitTime: 25.0),
    Ride(name: "Mountain Railroad", types: [.Family, .Relaxing], waitTime: 0.0)
]


func sortedNames(rides: [Ride]) -> [String] {
    var sortedRides = rides
    var i, j : Int
    var key: Ride
    
    // 1
    for (i = 0; i < sortedRides.count; i++) {
        key = sortedRides[i]
        
        // 2
        for (j = i; j > -1; j--) {
            if key.name.localizedCompare(sortedRides[j].name) == .OrderedAscending {
                sortedRides.removeAtIndex(j + 1)
                sortedRides.insert(key, atIndex: j)
            }
        }
    }
    
    // 3
    var sortedNames = [String]()
    for ride in sortedRides {
        sortedNames.append(ride.name)
    }
    
    print(sortedRides)
    
    return sortedNames
}

sortedNames(parkRides)


var originalNames = [String]()
for ride in parkRides {
    originalNames.append(ride.name)
}

print(originalNames)




func waitTimeIsShort(ride: Ride) -> Bool {
    return ride.waitTime < 15.0
}

var ahortraidTimes = parkRides.filter{ $0.waitTime < 15 }
print(ahortraidTimes.count)


var names = parkRides.map{ $0.name.characters.count /*+ " " + String($0.waitTime)*/ }.reduce(0) { $0 + $1 }
print(names)

//print(names.sort(<))

let finall = parkRides.filter{ $0.waitTime < 15 }.map{ $0.name }.sort(<)

print(finall)


let averageWaitTime = parkRides.reduce(0.0) { (average, ride) in average + (ride.waitTime/Double(parkRides.count)) }
print(averageWaitTime)


func ridesWithWaitTimeUnder(waitTime: Double, fromRides rides: [Ride]) -> [Ride] {
    return rides.filter { $0.waitTime < waitTime }
}




var shortWaitRides = ridesWithWaitTimeUnder(15.0, fromRides: parkRides)
assert(shortWaitRides.count == 2, "Count of short wait rides should be 2")
print(shortWaitRides)

shortWaitRides = parkRides.filter { $0.waitTime < 15.0 }
assert(shortWaitRides.count == 2, "Count of short wait rides should be 2")
print(shortWaitRides)



extension Ride: Comparable { }

func <(lhs: Ride, rhs: Ride) -> Bool {
    return lhs.waitTime < rhs.waitTime
}

func >(lhs: Ride, rhs: Ride) -> Bool {
    return lhs.waitTime > rhs.waitTime
}

func ==(lhs: Ride, rhs: Ride) -> Bool {
    return lhs.name == rhs.name
}

func quicksort<T: Comparable>(var elements: [T]) -> [T] {
    if elements.count > 1 {
        let pivot = elements.removeAtIndex(0)
        return quicksort(elements.filter { $0 <= pivot }) + [pivot] + quicksort(elements.filter { $0 > pivot })
    }
    return elements
}
print(quicksort(parkRides))
print(parkRides)



let haha = parkRides.filter{ $0.types.contains(.Family) && $0.waitTime < 20 }.sort(>)


print(haha)
print(haha.count)



var ridesOfInterest = [Ride]()
for ride in parkRides {
    var typeMatch = false
    for type in ride.types {
        if type == .Family {
            typeMatch = true
            break
        }
    }
    if typeMatch && ride.waitTime < 20.0 {
        ridesOfInterest.append(ride)
    }
}

var sortedRidesOfInterest = quicksort(ridesOfInterest)

print(sortedRidesOfInterest)

