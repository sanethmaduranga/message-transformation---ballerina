import ballerina/http;
import ballerina/log;
import ballerina/mime;
import ballerina/io;
import ballerina/mysql;

//define endpoints for services
endpoint http:Client validatorEP {
    url: "http://localhost:9094/validator"
};
endpoint http:Client enricherEP {
    url: "http://localhost:9092/enricher"
};
endpoint http:Client clientEP {
    url: "http://localhost:9093/backend"
};

//connect the student details table
endpoint mysql:Client testDB {
    host: "localhost",
    port: 3306,
    name: "testdb",
    username: "root",
    password: "wso2123",
    poolOptions: { maximumPoolSize: 5 },
    dbOptions: { useSSL: false }
};

//connect the student's results details table
endpoint mysql:Client testDB1 {
    host: "localhost",
    port: 3306,
    name: "testdb1",
    username: "root",
    password: "wso2123",
    poolOptions: { maximumPoolSize: 5 },
    dbOptions: { useSSL: false }
};

//define the global variables
public json payload1;
public json payload2;

//service for the content filter pattern
service<http:Service> contentfilter bind { port: 9090 } {
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    contentfilter(endpoint caller, http:Request req) {
        http:Request filteredreq = req;
        var jsonMsg = req.getJsonPayload();
        match jsonMsg {
            json msg => {
                //create the student table in the DB
                var ret = testDB->update(
                                      "CREATE TABLE student(id INT, name VARCHAR(255), city VARCHAR(255), gender VARCHAR(255))"
                );
                handleUpdate(ret, "Create the table");
                //Error handling for the user inputs
                if (!check msg.id.toString().matches("\\d+")) {
                    error err = { message: "student ID containts invalid data" };
                    http:Response res = new;
                    res.statusCode = 400;
                    res.setPayload(untaint err.message);
                    caller->respond(res) but { error e =>
                    log:printError("Error sending response", err = e) };
                } else if (!check msg.name.toString().matches("[a-zA-Z]+")) {
                    error err = { message: "student Name containts invalid data" };
                    http:Response res = new;
                    res.statusCode = 400;
                    res.setPayload(untaint err.message);
                    caller->respond(res) but { error e =>
                    log:printError("Error sending response", err = e) };
                }else if (!check msg.city.toString().matches("^[a-zA-Z]+([\\-\\s]?[a-zA-Z0-9]+)*$")) {
                    error err = { message: "student city containts invalid data" };
                    http:Response res = new;
                    res.statusCode = 400;
                    res.setPayload(untaint err.message);
                    caller->respond(res) but { error e =>
                    log:printError("Error sending response", err = e) };
                }else if (!check msg.gender.toString().matches("[a-zA-Z]+")) {
                    error err = { message: "student gender containts invalid data" };
                    http:Response res = new;
                    res.statusCode = 400;
                    res.setPayload(untaint err.message);
                    caller->respond(res) but { error e =>
                    log:printError("Error sending response", err = e) };
                }
                else {
                    //Assign user input values to variables
                    int Idvalue = check <int>msg["id"];
                    string nameString = check <string>msg["name"];
                    string cityString = check <string>msg["city"];
                    string genderString = check <string>msg["gender"];
                    //add values to the student details table
                    ret = testDB->update("INSERT INTO student(id, name, city, gender) values (?, ?, ?, ?)", Idvalue,
                        nameString, cityString, genderString);
                    handleUpdate(ret, "Add details to the table");
                    json iddetails= { id: Idvalue };
                    //set filtered payload to the request
                    filteredreq.setJsonPayload(untaint iddetails);
                    //forward request to the nesxt ID validating service
                    var clientResponse = validatorEP->forward("/", filteredreq);
                    match clientResponse {
                        http:Response res => {
                            caller->respond(res) but { error e =>
                            log:printError("Error sending response", err = e) };
                        }
                        error err => {
                            http:Response res = new;
                            res.statusCode = 500;
                            res.setPayload(err.message);
                            caller->respond(res) but { error e =>
                            log:printError("Error sending response", err = e) };
                        }
                    }
                }
            }
            error err => {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload( untaint err.message);
                caller->respond(res) but { error e =>
                log:printError("Error while content reading", err = e) };
            }
        }

    }
}

//the student ID validator service
service<http:Service> validator bind { port: 9094 } {
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    validator(endpoint caller, http:Request filteredreq) {
        http:Request validatededreq = filteredreq;
        //get the payload in the request (Student ID)
        var jsonMsg = filteredreq.getJsonPayload();
        match jsonMsg {
            json msg => {
                int Idvalue = check <int>msg["id"];
                //validate the student's ID
                //In this example student's ID should be in between 100 to 110
                if ((100 <= Idvalue)&&(Idvalue <= 110))  {
                    //print the validity
                    io:println("The  Student ID is succussfully validated");
                    //forward the request to the enricher service
                    var clientResponse = enricherEP->forward("/", validatededreq);
                    match clientResponse {
                        http:Response res => {
                            caller->respond(res) but { error e =>
                            log:printError("Error sending response", err = e) };
                        }
                        error err => {
                            http:Response res = new;
                            res.statusCode = 500;
                            res.setPayload(untaint err.message);
                            caller->respond(res) but { error e =>
                            log:printError("Error sending response", err = e) };
                        }
                    }
                }
                else {
                    error err = { message: "Student ID: " + Idvalue + " is not found" };
                    http:Response res = new;
                    res.statusCode = 500;
                    res.setPayload(untaint err.message);
                    caller->respond(res) but { error e =>
                    log:printError("Error sending response", err = e) };
                }
            }
            error err => {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload(untaint err.message);
                caller->respond(res) but { error e =>
                log:printError("Error while content reading", err = e) };
            }
        }

    }
}

//The content enricher service
service<http:Service> enricher bind { port: 9092 } {
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    enricher(endpoint caller, http:Request validatedreq) {
        http:Request enrichedreq = validatedreq;
        var jsonMsg = validatedreq.getJsonPayload();
        match jsonMsg {
            json msg => {
                //get the student's ID value
                int Idvalue = check <int>msg["id"];
                //select details from the data table according to the student's ID
                var selectRet = testDB->select("SELECT * FROM student", ());
                table dt;
                match selectRet {
                    table tableReturned => dt = tableReturned;
                    error e => io:println("Select data from student table failed: "
                            + e.message);
                }
                //convert the details to a jason file
                io:println("\nConvert the table into json");
                var jsonConversionRet = <json>dt;
                match jsonConversionRet {
                    json jsonRes => {
                        //set student's details to the global variable
                        payload1= untaint jsonRes;
                    }
                    error e => io:println("Error in student table to json conversion");
                }
                //drop the student details table
                var ret = testDB->update("DROP TABLE student");
                handleUpdate(ret, "Drop table student");
                //select student's results from the student results data table, according to the student's ID
                var selectRet1 = testDB1->select("select Com_Maths,Physics,Chemistry from StudentDetails where ID = ?", (), Idvalue);
                table dt1;
                match selectRet1 {
                    table tableReturned => dt1 = tableReturned;
                    error e => io:println("Select data from StudentDetails table failed: "
                            + e.message);
                }
                //convert the details to a jason file
                io:println("\nConvert the table into json");
                var jsonConversionRet1 = <json>dt1;
                match jsonConversionRet1 {
                    json jsonRes1 => {
                        //set student's result details to the global variable
                        payload2= untaint jsonRes1;
                    }
                    error e => io:println("Error in StudentDetails table to json conversion");
                }
                testDB.stop();

                //JSON to JSON conversion to the selected details
                //define new jason variable
                json pay = payload1[0];
                //add extra values to the jason payload
                pay.fname = pay.name;
                //remove values from the jason payload
                pay.remove("name");
                //add results to the same payload
                pay.results = payload2[0];
                //set enriched payload to the request
                enrichedreq.setJsonPayload(pay);
            }
            error err => {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload(untaint err.message);
                caller->respond(res) but { error e =>
                log:printError("Error sending response", err = e) };
            }
        }
        //forward enriched request to the client endpoint
        var clientResponse = clientEP->forward("/", enrichedreq);
        match clientResponse {
            http:Response res => {
                caller->respond(res) but { error e =>
                log:printError("Error sending response", err = e) };
            }
            error err => {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload(err.message);
                caller->respond(res) but { error e =>
                log:printError("Error sending response", err = e) };
            }
        }
    }
}

//client endpoint service to display the request payload
service<http:Service> backend bind { port: 9093 } {
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    backendservice (endpoint caller, http:Request enrichedreq) {
        //get the requset payload
        var jsonMsg = enrichedreq.getJsonPayload();
        match jsonMsg {
            json msg => {
                //send payload as response
                http:Response res = new;
                res.setJsonPayload(untaint msg);
                caller->respond(res) but { error e =>
                log:printError("Error sending response", err = e) };
            }
            error err => {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload(untaint err.message);
                caller->respond(res) but { error e =>
                log:printError("Error sending response", err = e) };
            }
        }
    }
}

//function for the error handling part in extract values from payload to variables
function handleUpdate(int|error returned, string message) {
    match returned {
        int retInt => io:println(message + " status: " + retInt);
        error e => io:println(message + " failed: " + e.message);
    }
}
