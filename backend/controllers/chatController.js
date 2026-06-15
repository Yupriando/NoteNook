const db = require("../config/db");
const path = require("path");
const fs = require("fs");
const { baseUrl } = require("../config/app");

exports.sendMessage = async (req, res) => {
  try {
    const { receiver_id, message } = req.body;

    if (!receiver_id) {
      return res.status(400).json({
        message: "receiver required",
      });
    }

    if (Number(receiver_id) === req.user.id) {
      return res.status(400).json({
        message: "cannot send message to yourself",
      });
    }

    const [users] = await db.execute(
      `
      SELECT id
      FROM users
      WHERE id=?
      `,
      [receiver_id],
    );

    if (users.length === 0) {
      return res.status(404).json({
        message: "receiver not found",
      });
    }

    if (
      (!message || message.trim() === "") &&
      (!req.files || req.files.length === 0)
    ) {
      return res.status(400).json({
        message: "message required",
      });
    }

    const [result] = await db.execute(
      `
      INSERT INTO chats(
        sender_id,
        receiver_id,
        message,
        read_status
      )
      VALUES(
        ?,
        ?,
        ?,
        FALSE
      )
      `,
      [req.user.id, receiver_id, message || null],
    );

    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        const url = `${file.filename}`;
        const ext = path.extname(file.originalname).toLowerCase();
        const imageExt = [".jpg", ".jpeg", ".png", ".gif", ".webp"];
        const type = imageExt.includes(ext) ? "image" : "file";

        await db.execute(
          `
          INSERT INTO chat_files(
            chat_id,
            file_url,
            file_type
          )
          VALUES(
            ?,
            ?,
            ?
          )
          `,
          [result.insertId, url, type],
        );
      }
    }

    const [files] = await db.execute(
      `
      SELECT *
      FROM chat_files
      WHERE chat_id=?
      `,
      [result.insertId],
    );

    const payload = {
      id: result.insertId,
      sender_id: req.user.id,
      receiver_id,
      message,
      files,
      created_at: new Date(),
    };

    const io = req.app.get("io");

    io.to(String(receiver_id)).emit("receive_message", payload);

    return res.status(201).json({
      message: "sent",
      data: payload,
    });
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.getConversation = async (req, res) => {
  try {
    const other = req.params.id;
    const [rows] = await db.execute(
      `
      SELECT
        c.id,
        c.message,
        c.created_at,
        u.name sender_name,
        c.sender_id
      FROM chats c
      JOIN users u
      ON c.sender_id=u.id
      WHERE
      (
        sender_id=?
        AND receiver_id=?
      )
      OR
      (
        sender_id=?
        AND receiver_id=?
      )
      ORDER BY created_at
      `,
      [req.user.id, other, other, req.user.id],
    );

    return res.json(rows);
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.getConversationList = async (req, res) => {
  try {
    const [rows] = await db.execute(
      `
      SELECT
      u.id user_id,
      u.name,
      u.profile_picture,
      u.role,
      c.message,
      c.created_at,
      (
        SELECT COUNT(*)
        FROM chats
        WHERE
        receiver_id=?
        AND
        sender_id=u.id
        AND
        read_status=FALSE
      ) unread
      FROM chats c
      JOIN users u
      ON u.id=
      IF(
        c.sender_id=?,
        c.receiver_id,
        c.sender_id
      )
      WHERE c.id IN(
        SELECT MAX(id)
        FROM chats
        WHERE
        sender_id=?
        OR receiver_id=?
        GROUP BY
        LEAST(
          sender_id,
          receiver_id
        ),
        GREATEST(
          sender_id,
          receiver_id
        )
      )
      ORDER BY c.created_at DESC
      `,
      [req.user.id, req.user.id, req.user.id, req.user.id],
    );

    return res.json(rows);
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.getMessages = async (req, res) => {
  try {
    const target = req.params.id;

    const [rows] = await db.execute(
      `
      SELECT
      c.id,
      c.sender_id,
      c.receiver_id,
      u.name,
      u.profile_picture,
      c.message,
      c.read_status,
      c.created_at
      FROM chats c
      JOIN users u
      ON c.sender_id=u.id
      WHERE
      (
        sender_id=?
        AND receiver_id=?
      )
      OR
      (
        sender_id=?
        AND receiver_id=?
      )
      ORDER BY created_at ASC
      `,
      [req.user.id, target, target, req.user.id],
    );

    for (const chat of rows) {
      const [files] = await db.execute(
        `
        SELECT *
        FROM chat_files
        WHERE chat_id=?
        `,
        [chat.id],
      );

      chat.files = files;
    }

    return res.status(200).json(rows);
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.markRead = async (req, res) => {
  try {
    await db.execute(
      `
      UPDATE chats
      SET read_status=TRUE
      WHERE
      sender_id=?
      AND
      receiver_id=?
      `,
      [req.params.id, req.user.id],
    );

    return res.json({
      message: "read",
    });
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.downloadFile = (req, res) => {
  const filePath = path.join(__dirname, "../uploads/chat", req.params.filename);

  if (!fs.existsSync(filePath)) {
    return res.status(404).json({
      message: "file not found",
    });
  }

  return res.download(filePath);
};
