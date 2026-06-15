const { baseUrl } = require("../config/app");
const db = require("../config/db");
const path = require("path");

exports.createNote = async (req, res) => {
  try {
    const { title, description, visibility, folder_id } = req.body;
    const [result] = await db.execute(
      `
      INSERT INTO notes(

      user_id,
      folder_id,
      title,
      description,
      visibility

      )

      VALUES(

      ?,
      ?,
      ?,
      ?,
      ?

      )
      `,
      [req.user.id, folder_id || null, title, description, visibility],
    );

    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        const url = `${file.filename}`;
        const ext = path.extname(file.originalname).toLowerCase();

        const imageExt = [".jpg", ".jpeg", ".png", ".gif", ".webp"];

        const type = imageExt.includes(ext) ? "image" : "file";

        await db.execute(
          `
          INSERT INTO note_files(

          note_id,
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

    return res.status(201).json({
      message: "created",
      id: result.insertId,
    });
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.getMyNotes = async (req, res) => {
  try {
    const [rows] = await db.execute(
      `
      SELECT *
      FROM notes
      WHERE user_id=?
      ORDER BY updated_at DESC
      `,
      [req.user.id],
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
      message: "error",
    });
  }
};

exports.updateNote = async (req, res) => {
  try {
    const { title, description, visibility, folder_id } = req.body;

    await db.execute(
      `
      UPDATE notes
      SET
      folder_id=?,
      title=?,
      description=?,
      visibility=?
      WHERE
      id=?
      AND
      user_id=?
      `,
      [
        folder_id || null,
        title,
        description,
        visibility,
        req.params.id,
        req.user.id,
      ],
    );

    if (req.files && req.files.length > 0) {
      await db.execute(
        `
        DELETE FROM note_files
        WHERE note_id=?
        `,
        [req.params.id],
      );

      for (const file of req.files) {
        const url = `${file.filename}`;
        const ext = path.extname(file.originalname).toLowerCase();
        const imageExt = [".jpg", ".jpeg", ".png", ".gif", ".webp"];
        const type = imageExt.includes(ext) ? "image" : "file";

        await db.execute(
          `
          INSERT INTO note_files(
          note_id,
          file_url,
          file_type
          )
          VALUES(
          ?,
          ?,
          ?
          )
          `,
          [req.params.id, url, type],
        );
      }
    }

    return res.json({
      message: "updated",
    });
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.deleteNote = async (req, res) => {
  try {
    await db.execute(
      `
      DELETE FROM bookmarks
      WHERE note_id=?
      `,
      [req.params.id],
    );

    await db.execute(
      `
      DELETE FROM note_files
      WHERE note_id=?
      `,
      [req.params.id],
    );

    await db.execute(
      `
      DELETE FROM notes
      WHERE
      id=?
      AND
      user_id=?
      `,
      [req.params.id, req.user.id],
    );

    return res.json({
      message: "deleted",
    });
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: "error",
    });
  }
};

exports.getPublicNotes = async (req, res) => {
  try {
    const [rows] = await db.execute(
      `
      SELECT
      notes.id,
      notes.user_id,
      notes.folder_id,
      notes.title,
      notes.description,
      notes.visibility,
      notes.created_at,
      notes.updated_at,
      users.name,
      users.profile_picture,
      users.role,
      EXISTS(
      SELECT 1
      FROM bookmarks
      WHERE
      bookmarks.note_id=notes.id
      AND
      bookmarks.user_id=?
      ) AS bookmarked
      FROM notes
      JOIN users
      ON notes.user_id=users.id
      WHERE
      notes.visibility='public'
      ORDER BY notes.created_at DESC
      `,
      [req.user.id],
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

    return res.status(200).json(rows);
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.bookmarkNote = async (req, res) => {
  try {
    await db.execute(
      `
      INSERT INTO bookmarks(
      user_id,
      note_id
      )
      VALUES(
      ?,
      ?
      )
      `,
      [req.user.id, req.params.id],
    );

    return res.status(201).json({
      message: "bookmarked",
    });
  } catch (error) {
    console.log(error);

    if (error.code === "ER_DUP_ENTRY") {
      return res.status(400).json({
        message: "already bookmarked",
      });
    }

    return res.status(500).json({
      message: "server error",
    });
  }
};

exports.getBookmarks = async (req, res) => {
  try {
    const [rows] = await db.execute(
      `
      SELECT
      notes.id,
      notes.user_id,
      notes.folder_id,
      notes.title,
      notes.description,
      notes.visibility,
      notes.created_at,
      notes.updated_at,
      users.name,
      users.profile_picture,
      users.role,
      1 AS bookmarked
      FROM bookmarks
      JOIN notes
      ON bookmarks.note_id=notes.id
      JOIN users
      ON notes.user_id=users.id
      WHERE
      bookmarks.user_id=?
      `,
      [req.user.id],
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
      message: "error",
    });
  }
};

exports.removeBookmark = async (req, res) => {
  try {
    await db.execute(
      `
      DELETE FROM bookmarks
      WHERE
      user_id=?
      AND
      note_id=?
      `,
      [req.user.id, req.params.id],
    );

    return res.json({
      message: "removed",
    });
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: "error",
    });
  }
};

exports.searchNotes = async (req, res) => {
  try {
    const q = `%${req.query.q}%`;
    const [rows] = await db.execute(
      `
      SELECT
      notes.id,
      notes.user_id,
      notes.folder_id,
      notes.title,
      notes.description,
      notes.visibility,
      notes.created_at,
      notes.updated_at,
      folders.name AS folder_name,
      users.name,
      users.profile_picture,
      users.role,
      EXISTS(
      SELECT 1
      FROM bookmarks
      WHERE
      bookmarks.note_id=notes.id
      AND
      bookmarks.user_id=?
      ) AS bookmarked
      FROM notes
      LEFT JOIN folders
      ON notes.folder_id=folders.id
      JOIN users
      ON notes.user_id=users.id
      WHERE
      (
      notes.title LIKE ?
      OR
      notes.description LIKE ?
      OR
      users.name LIKE ?
      OR
      folders.name LIKE ?
      )
      AND
      (
      notes.user_id=?
      OR
      notes.visibility='public'
      )
      ORDER BY notes.updated_at DESC
      `,
      [req.user.id, q, q, q, q, req.user.id],
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
      message: "error",
    });
  }
};

exports.mySearchNotes = async (req, res) => {
  try {
    const q = `%${req.query.q}%`;

    const [rows] = await db.execute(
      `
      SELECT
      notes.id,
      notes.user_id,
      notes.folder_id,
      notes.title,
      notes.description,
      notes.visibility,
      notes.created_at,
      notes.updated_at,
      folders.name AS folder_name,
      users.name,
      users.profile_picture,
      users.role,
      EXISTS(
      SELECT 1
      FROM bookmarks
      WHERE
      bookmarks.note_id=notes.id
      AND
      bookmarks.user_id=?
      ) AS bookmarked
      FROM notes
      LEFT JOIN folders
      ON notes.folder_id=folders.id
      JOIN users
      ON notes.user_id=users.id
      WHERE
      notes.user_id=?
      AND
      (
      notes.title LIKE ?
      OR
      notes.description LIKE ?
      OR
      folders.name LIKE ?
      )
      ORDER BY notes.updated_at DESC
      `,
      [req.user.id, req.user.id, q, q, q],
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
      message: "error",
    });
  }
};

exports.filterNotes = async (req, res) => {
  try {
    const visibility = req.query.visibility;
    const sort = req.query.sort;
    let sql = `
      SELECT
      notes.id,
      notes.user_id,
      notes.folder_id,
      notes.title,
      notes.description,
      notes.visibility,
      notes.updated_at,
      users.name,
      users.profile_picture,
      users.role
      FROM notes
      JOIN users
      ON notes.user_id=users.id
      WHERE 1=1
      `;

    let params = [];

    if (visibility) {
      sql += `
      AND notes.visibility=?
      `;

      params.push(visibility);
    }

    if (sort === "oldest") {
      sql += `
      ORDER BY updated_at ASC
      `;
    } else {
      sql += `
      ORDER BY updated_at DESC
      `;
    }

    const [rows] = await db.execute(sql, params);

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
      message: "error",
    });
  }
};

const fs = require("fs");

exports.downloadNoteFile = async (req, res) => {
  const file = path.join(__dirname, "../uploads/notes", req.params.filename);

  if (!fs.existsSync(file)) {
    return res.status(404).json({
      message: "file not found",
    });
  }

  return res.download(file, req.params.filename);
};
