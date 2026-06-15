const { baseUrl } = require("../config/app");
const db = require("../config/db");
const bcrypt = require("bcrypt");

exports.profile = async (req, res) => {
  try {
    const [users] = await db.execute(
      `
      SELECT
      id,
      name,
      email,
      phone,
      role,
      profile_picture,
      bio,
      (
        SELECT COUNT(*)
        FROM notes
        WHERE notes.user_id=users.id
      ) AS total_notes,
      (
        SELECT COUNT(*)
        FROM comments
        WHERE comments.user_id=users.id
      ) AS total_comments,
      (
        SELECT COUNT(*)
        FROM bookmarks
        WHERE bookmarks.user_id=users.id
      ) AS total_bookmarks
      FROM users
      WHERE id=?
      `,
      [req.user.id],
    );

    return res.json(users[0]);
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { name, phone, email, bio } = req.body;

    if (!name || !email) {
      return res.status(400).json({
        message: "name and email required",
      });
    }

    const [existing] = await db.execute(
      `
      SELECT id
      FROM users
      WHERE
      email=?
      AND id!=?
      `,
      [email, req.user.id],
    );

    if (existing.length > 0) {
      return res.status(409).json({
        message: "email already exists",
      });
    }

    let image = null;

    if (req.file) {
      image = `${req.file.filename}`;
    }

    await db.execute(
      `
      UPDATE users
      SET
      name=?,
      phone=?,
      email=?,
      bio=?,
      profile_picture=
      COALESCE(
        ?,
        profile_picture
      )
      WHERE id=?
      `,
      [name, phone, email, bio, image, req.user.id],
    );

    return res.json({
      message: "profile updated",
    });
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: "update failed",
    });
  }
};

exports.changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword, confirmPassword } = req.body;

    if (!oldPassword || !newPassword || !confirmPassword) {
      return res.status(400).json({
        message: "all fields required",
      });
    }

    if (newPassword.length < 8) {
      return res.status(400).json({
        message: "password must be at least 8 characters",
      });
    }

    if (newPassword !== confirmPassword) {
      return res.status(400).json({
        message: "password confirmation mismatch",
      });
    }

    const [users] = await db.execute(
      `
      SELECT password
      FROM users
      WHERE id=?
      `,
      [req.user.id],
    );

    const user = users[0];

    const valid = await bcrypt.compare(oldPassword, user.password);

    if (!valid) {
      return res.status(401).json({
        message: "old password incorrect",
      });
    }

    const hash = await bcrypt.hash(newPassword, 10);

    await db.execute(
      `
      UPDATE users
      SET password=?
      WHERE id=?
      `,
      [hash, req.user.id],
    );

    return res.json({
      message: "password updated",
    });
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: "server error",
    });
  }
};

exports.getMentors = async (req, res) => {
  try {
    const [rows] = await db.execute(
      `
      SELECT
      id,
      name,
      email,
      phone,
      profile_picture,
      role
      FROM users
      WHERE id != ?
      ORDER BY name
      `,
      [req.user.id],
    );

    return res.status(200).json(rows);
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: "server error",
    });
  }
};

exports.getUserProfile = async (req, res) => {
  try {
    const [rows] = await db.execute(
      `
      SELECT
      id,
      name,
      role,
      profile_picture,
      bio,
      (
        SELECT COUNT(*)
        FROM notes
        WHERE notes.user_id=users.id
      ) AS total_notes,
      (
        SELECT COUNT(*)
        FROM comments
        WHERE comments.user_id=users.id
      ) AS total_comments,
      (
        SELECT COUNT(*)
        FROM bookmarks
        WHERE bookmarks.user_id=users.id
      ) AS total_bookmarks
      FROM users
      WHERE id=?
      `,
      [req.params.id],
    );

    if (rows.length === 0) {
      return res.status(404).json({
        message: "user not found",
      });
    }

    return res.json(rows[0]);
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.becomeMentor = async (req, res) => {
  try {
    const [users] = await db.execute(
      `
      SELECT role
      FROM users
      WHERE id=?
      `,
      [req.user.id],
    );

    if (users[0].role === "mentor") {
      return res.status(400).json({
        message: "already mentor",
      });
    }

    await db.execute(
      `
      UPDATE users
      SET role='mentor'
      WHERE id=?
      `,
      [req.user.id],
    );

    return res.json({
      message: "success",
    });
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.getUserNotes = async (req, res) => {
  try {
    const [rows] = await db.execute(
      `
      SELECT
      notes.*,
      users.name,
      users.profile_picture,
      users.role
      FROM notes
      JOIN users
      ON notes.user_id=users.id
      WHERE
      notes.user_id=?
      AND
      notes.visibility='public'
      ORDER BY notes.created_at DESC
      `,
      [req.params.id],
    );

    for (const note of rows) {
      const [files] = await db.execute(
        `
        SELECT *
        FROM note_files
        WHERE note_id=?
        `,
        [note.id],
      );

      note.files = files;
    }

    return res.json(rows);
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};
