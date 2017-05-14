import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import StORM
import PostgresStORM

PostgresConnector.host     = "localhost"
PostgresConnector.username = "perfect_barta"
PostgresConnector.password = "Tamanna25T"
PostgresConnector.database = "perfect_barta_test"
PostgresConnector.port     = 5432

let setupObj = Acronym()
try? setupObj.setup()


let server = HTTPServer()
server.serverPort = 8080

var routes = Routes()

func test(request: HTTPRequest, response: HTTPResponse) {
    do {
        // Save Acronym
        let  acronym = Acronym()
        acronym.short = "AFK"
        acronym.long  = "Away from keyboard"
        
        try acronym.save { id in
            acronym.id = id as! Int
        }
        
        // get all acronym as dictionary
        let getObj = Acronym()
        try getObj.findAll()
        var acronyms: [[String: Any]] = []
        for row in getObj.rows() {
            acronyms.append(row.asDictionary())
        }
        
        try response.setBody(json: acronyms)
                    .setHeader(.contentType, value: "application/json")
                    .completed()
        
    } catch {
        response.setBody(string: "Error handling request: \(error)")
            .completed(status: .internalServerError)
    }
}

func new(request: HTTPRequest, response: HTTPResponse) {
    do {
        guard let json = request.postBodyString,
        let dict  = try json.jsonDecode() as? [String: String],
        let short = dict["short"],
        let long  = dict["long"] else {
        response.completed(status: .badRequest)
        return
    }
        // Save Acronym
        let acronym = Acronym()
        acronym.short = short
        acronym.long  = long
        try acronym.save() { id in
            acronym.id = id as! Int
        }
        
        try response.setBody(json: acronym.asDictionary())
            .setHeader(.contentType, value: "application/json")
            .completed()
        
    } catch {
        response.setBody(string: "Error handling request: \(error)")
            .completed(status: .internalServerError)
    }
}

func all(request: HTTPRequest, response: HTTPResponse) {
    
    do {
        // Get all acrynyms as a dictinary
        let getObj = Acronym()
        try getObj.findAll()
        var acronyms: [[String: Any]] = []
        for row in getObj.rows() {
            acronyms.append(row.asDictionary())
        }
        
        try response.setBody(json: acronyms)
                    .setHeader(.contentType, value: "application/josn")
                    .completed()
    } catch {
        response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
    }
}
routes.add(method: .get,  uri: "/test", handler: test)
routes.add(method: .post, uri: "/new", handler: new)
routes.add(method: .get, uri: "/all", handler: all)



server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
