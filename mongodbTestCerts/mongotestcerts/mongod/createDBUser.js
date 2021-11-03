db.getSiblingDB('$external').runCommand(
    {
      createUser: "CHANGEME",
      roles: [
           { role: 'root', db: 'admin' }
      ],
      writeConcern: { w: 'majority' , wtimeout: 5000 }
    }
  )
  db.getSiblingDB("admin").shutdownServer()