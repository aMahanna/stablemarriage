package main

import (
    "bufio"
    "encoding/csv"
    "fmt"
    "io"
    "log"
    "os"
    "sync"
)

type Match struct {  // Struct Match
  student *Student   // Holds Student pointer
  employer *Employer // Holds Employer pointer
}

// Struct Student
type Student struct {
  name string           // Student Name
  match Match           // Student's match
  iterator int          // Student iterator (not really useful)
  isMatched bool        // Boolean value to show if Student has been matched
  prefList []*Employer  // Preference List of Employers (As seen in the CSV files provided)
}

type Employer struct {  
  name string           // Employer Name
  match Match           // Employer's match
  iterator int          // Iterator used to keep track of the next Student that this Employer will send an offer to (closestUnofferedStudent)
  isMatched bool        // Boolean value to show if Employer has been matched
  prefList []*Student   // Preference List of Students (As seen in the CSV files provided)
}

/*
  Function createMaps()

  Reads the CSV files provided
  Creates studentMap with key = student name (string) and value = student instance

*/
func createMaps(studentFileName string, employerFileName string, studentMap map[string]*Student, employerMap map[string]*Employer) (employerNameList []string) {
  studentCSVFile, _ := os.Open(studentFileName)
  studentReader := csv.NewReader(bufio.NewReader(studentCSVFile))

  employerCSVFile, _ := os.Open(employerFileName)
  employerReader := csv.NewReader(bufio.NewReader(employerCSVFile))

  for {                                                               // Loop until no lines are left to read
    studentLine, studentError := studentReader.Read()               // Represents the current line in the list_students.csv file
    employerLine, employerError := employerReader.Read()            // Represents the current line in the list_employers.csv file

    if studentError == io.EOF || employerError == io.EOF {
        break                                                         // No more lines, break loop
    } else if studentError != nil || employerError != nil {
        log.Fatal(studentError)
    }
        
    createdStudent := Student{studentLine[0], Match{}, 0, false, make([]*Employer, 10)}   // Student instance created 
    studentMap[studentLine[0]] = &createdStudent                                          // Store address of newly created Student instance in map (use student name as the key value)

    createdEmployer := Employer{employerLine[0], Match{}, 0, false, make([]*Student, 10)} // Employer instance created 
    employerMap[employerLine[0]] = &createdEmployer                                       // Store address of newly created Employer instance in map (use employer name as the key value)

    employerNameList = append(employerNameList, employerLine[0])                          // employerNameList stores all the names (string) of each employer
          
  }

  return employerNameList

}

/*
  Function establishPreferences()

  Reads the CSV files provided
  Updates the prefList attribute of each Student and Employer instance in studentMap and employerMap

  This function essentially copies the preference information provided by the CSV files
  The prefList attribute is heavily used in the offer() and evaluate() functions, which is why this function is needed

*/
func establishPreferences(studentFileName string, employerFileName string, studentMap map[string]*Student, employerMap map[string]*Employer) {
  studentCSVFile, _ := os.Open(studentFileName)
    studentReader := csv.NewReader(bufio.NewReader(studentCSVFile))

    employerCSVFile, _ := os.Open(employerFileName)
    employerReader := csv.NewReader(bufio.NewReader(employerCSVFile))  

    var currentEmployer *Employer
    var currentStudent *Student

    for {

        studentLine, studentError := studentReader.Read()
        employerLine, employerError := employerReader.Read()

        if studentError == io.EOF || employerError == io.EOF {
            break
        } else if studentError != nil || employerError != nil {
            log.Fatal(studentError)
        }

        currentEmployer = employerMap[employerLine[0]]          // Assign current employer

        for i := 1; i < 11; i++ {                               // Loop through length of currentEmployer's prefList (10)
          iStudent := studentMap[employerLine[i]]               // Take the iTH student instance found at the iTH index of the current employerLine
          currentEmployer.prefList[i-1] = iStudent              // Append the iTH student instance to the currentEmployer's preference list
        }


        currentStudent = studentMap[studentLine[0]]             // Assign current employer

        for i:= 1; i < 11; i++ {                                // Loop through length of currentStudent's prefList (10)
          iEmployer := employerMap[studentLine[i]]              // Take the iTH employer instance found at the iTH index of the current studentLine
          currentStudent.prefList[i-1] = iEmployer              // Append the iTH employer instance to the currentStudent's preference list
        }

       
    }
}

/*
  findEmployerRank()

  This METHOD loops through the preference list of a specific student until it
  finds the employer that was passed as a parameter.

  It returns the position of the employer's placement in this student's preference list
  This method is used to find out if a student prefers a new employer over its current employer

*/
func (student Student) findEmployerRank(employer *Employer) (i int) {
  for i := 0; i < 10; i++ {                                             // Loop through prefList (10)
    if (student.prefList[i].name == employer.name) {                    // If employer at position i is equal to the name of the employer passed by parameter
      return i                                                          // Return the "rank" of that employer
    }
  }

  return -1                                                             // If not found, return -1 (this never happens)
}

/*

  offer()

  Finds the closest student in e's prefList that has yet to receive an offer from employer e.
  Calls evaluate() to see if employer e and closestUnofferedStudent can be a match

*/
func offer(e *Employer, matchList []*Match) {

  var closestUnofferedStudent *Student 

  if (!e.isMatched) { // If employer is unmatched

    if (e.iterator > 9) {
      return // Safety net (this never happens)
    }

    closestUnofferedStudent = e.prefList[e.iterator]  // Use e.iterator to retrieve the next student on the employer's preference list
    e.iterator++                                      // Update employer iterator
  
    evaluate(e, closestUnofferedStudent, matchList)   // Call evalute()
    
  }

  return
}


/*
  evaluate()

  Handles the matching of an employer and a specific student

  If student is not matched -> Immediately create a match

  Else (student is matched):

    If student prefers new employer over old employer -> Update student's match && Reset oldEmployer's match && call offer(oldEmployer)

    Else, call offer() using the same employer to fetch the next closest unoffered student that is in line

*/
func evaluate(e *Employer, s *Student, matchList []*Match) {

  if (!s.isMatched) {                                         // Student is not matched
    var newMatch Match = Match{s, e}                          // Create match

    e.match = newMatch                                        // Set employer's match to newMatch
    s.match = newMatch                                        // Set student's match to newMatch

    e.isMatched = true                                        // Update isMatched bool for employer
    s.isMatched = true                                        // Update isMatched bool for student

    for i:=0; i<10; i++ {                                     // Loop through matchList and find first empty spot
      if (matchList[i] == nil) {        
        matchList[i] = &newMatch                              // Added newMatch's pointer at first empty spot in matchList
        break                                                 // Break loop, exit evaluate()
      }
    }
    
  } else {    // Student already has a match

      // Check if student prefers new employer over employer that they are currently matched with
      var studentPrefersNewEmployer bool = s.findEmployerRank(e) < s.findEmployerRank(s.match.employer)

    

      if (studentPrefersNewEmployer) {                              // If student prefers new employer

        var oldEmployer *Employer = s.match.employer                // Retrieve old employer
        oldEmployer.match = Match{nil, nil}                         // Reset old Employer's match
        oldEmployer.isMatched = false                               // Update isMatched bool back to false
        oldEmployer.iterator = 0                                    // Reset prefList iterator (to avoid bugs)

        s.match.employer = e                                        // Update student match to hold new employer
        e.match = s.match                                           // Update new employer's  match
        e.isMatched = true                                          // Update isMatched bool for new employer

        for i:=0; i < 10; i++ {                                     // Loop through matchList, find match associated to the current student
          if (matchList[i].student.name == s.name) {

            var updatedMatch Match = s.match
            matchList[i] = &updatedMatch                            // Place the updated match back at the same spot where the old match used to be

            break // Break and continue
          }

        }

        /* *********** Since oldEmployer no longer has a match, call offer() to find oldEmployer a new match *********** */
        
        var wg sync.WaitGroup                                       // Wait Group Created
        wg.Add(1)                                                   // Add one counter for the following Offer() goroutine

        go func(oE *Employer, mL []*Match) {                        // Goroutine Lambda Function

          defer wg.Done()                                           // Signal waitgroup when goroutine is done
          offer(oE, mL)                                             // Call offer with oldEmployer as parameter

        } (oldEmployer, matchList)                                  // Lambda Function Parameters

        wg.Wait()                                                   // Wait
       

      } else {

        /* ********* Student does not prefer new employer, call offer() to find another possible student to match with Employer e  ******** */

        var wg sync.WaitGroup                                       // Wait Group Created
        wg.Add(1)                                                   // Add one counter for the following Offer() goroutine                  

        go func (nE *Employer, mL []*Match) {                       // Goroutine Lambda Function

          defer wg.Done()                                           // Signal waitgroup when goroutine is done
          offer(e, matchList)                                       // Call offer with newEmployer as parameter

        } (e, matchList)                                            // Lambda Function Parameters

        wg.Wait()                                                   // Wait
    
      }
  }

  return

}


func main() {

  var studentMap map[string]*Student = make(map[string]*Student)              
  var employerMap map[string]*Employer = make(map[string]*Employer)
    
  employerNameList := createMaps("list_students.csv", "list_employers.csv", studentMap, employerMap) 

  establishPreferences("list_students.csv", "list_employers.csv", studentMap, employerMap)

  var matchList []*Match = make([]*Match, 10) // List that stores the addresses of each match created

  var waitG sync.WaitGroup                    // Wait Group Created 

  

    for _,name := range employerNameList {          // Loop through each employer
      
      waitG.Add(1)                                  // Add 1 goroutine to waitgroup counter

      go func(e *Employer, mL []*Match) {           // Lambda goroutine

        defer waitG.Done()                          // Call Done() when goroutine finished
        offer(e, mL)                                // Call offer() using Lambda Function Parameters

      }(employerMap[name], matchList)               // <- Lambda Function Parameters

      waitG.Wait()                                  // Wait for goroutine to finish

    }


    fmt.Println("\nThe following output can also be found in the CSV file matches_go.csv")

    for _, match := range matchList {       // Loop through each match and display match info
      fmt.Println()
      fmt.Print(match.student.name)
      fmt.Print(" - ")
      fmt.Print(match.employer.name)
    }

    /******************************************** The following code below creates a CSV file of the output   **********************************/

    file, _ := os.Create("matches_go.csv")      
    defer file.Close()

    writer := csv.NewWriter(file)
    defer writer.Flush()

    for _, match := range matchList {                                       // Loop through each match in matchList
      currentMatch := []string{match.student.name, match.employer.name}     // Create a string slice with student name and employer name
      writer.Write(currentMatch)                                            // Copy slice info into csv file columns
    }

    fmt.Println()
    fmt.Println()
    fmt.Println("CSV File created")
  
}

