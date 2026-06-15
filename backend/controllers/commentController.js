const db = require("../config/db");

exports.createComment = async (req, res) => {
  try {
    const { note_id, comment, parent_id } = req.body;

    if (!note_id) {
      return res.status(400).json({
        message: "note id required",
      });
    }

    if (!comment || comment.trim() === "") {
      return res.status(400).json({
        message: "comment required",
      });
    }

    const [notes] = await db.execute(
      `
      SELECT id
      FROM notes
      WHERE id=?
      `,
      [note_id],
    );

    if (notes.length === 0) {
      return res.status(404).json({
        message: "note not found",
      });
    }

    if (parent_id) {
      const [parents] = await db.execute(
        `
        SELECT id
        FROM comments
        WHERE id=?
        `,
        [parent_id],
      );

      if (parents.length === 0) {
        return res.status(404).json({
          message: "parent comment not found",
        });
      }
    }

    const [result] = await db.execute(
      `
      INSERT INTO comments(
        note_id,
        user_id,
        parent_id,
        comment
      )
      VALUES(
        ?,
        ?,
        ?,
        ?
      )
      `,
      [note_id, req.user.id, parent_id || null, comment.trim()],
    );

    const [rows] = await db.execute(
      `
      SELECT
      comments.*,
      users.name,
      users.profile_picture
      FROM comments
      JOIN users
      ON comments.user_id=users.id
      WHERE comments.id=?
      `,
      [result.insertId],
    );

    const io = req.app.get("io");

    io.emit("receive_comment", rows[0]);

    return res.status(201).json(rows[0]);
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.getComments = async (req, res) => {
  try {
    const noteId = req.params.noteId;

    const [rows] = await db.execute(
      `
      SELECT
      comments.*,
      users.name,
      users.profile_picture
      FROM comments
      JOIN users
      ON comments.user_id=users.id
      WHERE comments.note_id=?
      ORDER BY comments.created_at ASC
      `,
      [noteId],
    );

    return res.json(rows);
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.deleteComment = async (req, res) => {
  try {
    const [comments] = await db.execute(
      `
      SELECT id
      FROM comments
      WHERE
      id=?
      AND user_id=?
      `,
      [req.params.id, req.user.id],
    );

    if (comments.length === 0) {
      return res.status(404).json({
        message: "comment not found or access denied",
      });
    }

    await db.execute(
      `
      DELETE FROM comments
      WHERE
      id=?
      AND user_id=?
      `,
      [req.params.id, req.user.id],
    );

    const io = req.app.get("io");

    io.emit("delete_comment", {
      id: req.params.id,
    });

    return res.json({
      message: "deleted",
    });
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};
