require("dotenv").config();

const express = require("express");
const cors = require("cors");
const http = require("http");

const swaggerUi = require("swagger-ui-express");
const swaggerSpec = require("./docs/swagger");

const { Server } = require("socket.io");

const auth = require("./routes/authRoute");
const user = require("./routes/userRoute");
const chat = require("./routes/chatRoute");
const notes = require("./routes/noteRoute");
const folder = require("./routes/folderRoute");
const commentRoute = require("./routes/commentRoute");

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

app.set("io", io);

const onlineUsers = new Map();
const lastSeen = {};

app.use(cors());
app.use(express.json());
app.use(
  express.urlencoded({
    extended: true,
  }),
);

app.use("/uploads", express.static("uploads"));
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));
app.use("/auth", auth);
app.use("/user", user);
app.use("/chat", chat);
app.use("/notes", notes);
app.use("/folders", folder);
app.use("/comments", commentRoute);

io.on("connection", (socket) => {
  console.log("user connected");

  socket.on("join", (userId) => {
    socket.userId = userId;

    if (!onlineUsers.has(userId)) {
      onlineUsers.set(userId, new Set());
    }

    onlineUsers.get(userId).add(socket.id);

    io.emit("online_users", Array.from(onlineUsers.keys()));

    socket.join(String(userId));
  });

  socket.on("typing", (data) => {
    io.to(String(data.receiverId)).emit("typing", {
      senderId: data.senderId,
    });
  });

  socket.on("message_read", (data) => {
    io.to(String(data.targetUserId)).emit("message_read");
  });

  socket.on("get_last_seen", (targetUserId) => {
    socket.emit("last_seen", lastSeen[targetUserId] || null);
  });

  socket.on("disconnect", () => {
    const userId = socket.userId;

    if (userId && onlineUsers.has(userId)) {
      onlineUsers.get(userId).delete(socket.id);

      if (onlineUsers.get(userId).size === 0) {
        onlineUsers.delete(userId);
      }
    }

    io.emit("online_users", Array.from(onlineUsers.keys()));

    if (userId) {
      lastSeen[userId] = new Date();
    }

    console.log("user disconnected");
  });
});

server.listen(3000, () => {
  console.log("server running");
});
