const express = require("express");
var http = require("http");
const app = express();
const port = process.env.PORT || 5000;
var server = http.createServer(app);
var io = require("socket.io")(server);
var clients = {};
var GroupClients = {};

//middlewre
app.use(express.json());
const routes = require("./routes.js");
app.use("/routes", routes);

io.on("connection", (socket) => {
  socket.on("signIn", (chatID) => {
    socket.join(chatID);
  });

  socket.on("message", (e) => {
    io.to(e.chatID).emit("message", e);
  });

  socket.on("groupMessage", (msg) => {
    io.to(msg.chatID).emit("groupMessage", msg);
  });

  // sign out
  socket.on("signOut", (chatID) => {
    socket.leave(chatID);
  });
});

app.route("/check").get((req, res) => {
  res.send("Server is up and running");
});

server.listen(port, "0.0.0.0", () => {
  console.log("server started");
});
