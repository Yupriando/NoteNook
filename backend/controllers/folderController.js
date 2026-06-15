const db = require("../config/db");

const deleteFolderRecursive = async (folderId, userId) => {
  const [children] = await db.execute(
    `
    SELECT id
    FROM folders
    WHERE
    parent_id=?
    AND
    user_id=?
    `,
    [folderId, userId],
  );

  for (const child of children) {
    await deleteFolderRecursive(child.id, userId);
  }

  await db.execute(
    `
    DELETE
    FROM bookmarks
    WHERE note_id IN (
      SELECT id
      FROM notes
      WHERE
      folder_id=?
      AND
      user_id=?
    )
    `,
    [folderId, userId],
  );

  await db.execute(
    `
    DELETE
    FROM notes
    WHERE
    folder_id=?
    AND
    user_id=?
    `,
    [folderId, userId],
  );

  await db.execute(
    `
    DELETE
    FROM folders
    WHERE
    id=?
    AND
    user_id=?
    `,
    [folderId, userId],
  );
};

exports.createFolder = async (req, res) => {
  try {
    const { name, parent_id } = req.body;

    if (!name || name.trim() === "") {
      return res.status(400).json({
        message: "folder name required",
      });
    }

    if (parent_id) {
      const [folders] = await db.execute(
        `
        SELECT id
        FROM folders
        WHERE
        id=?
        AND
        user_id=?
        `,
        [parent_id, req.user.id],
      );

      if (folders.length === 0) {
        return res.status(404).json({
          message: "parent folder not found",
        });
      }
    }

    const [result] = await db.execute(
      `
      INSERT INTO folders(
        user_id,
        name,
        parent_id
      )
      VALUES(
        ?,
        ?,
        ?
      )
      `,
      [req.user.id, name.trim(), parent_id || null],
    );

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

exports.getFolders = async (req, res) => {
  try {
    const [rows] = await db.execute(
      `
      SELECT *
      FROM folders
      WHERE
      user_id=?
      ORDER BY created_at DESC
      `,
      [req.user.id],
    );

    return res.json(rows);
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.renameFolder = async (req, res) => {
  try {
    const { name } = req.body;

    if (!name || name.trim() === "") {
      return res.status(400).json({
        message: "folder name required",
      });
    }

    const [folders] = await db.execute(
      `
      SELECT id
      FROM folders
      WHERE
      id=?
      AND
      user_id=?
      `,
      [req.params.id, req.user.id],
    );

    if (folders.length === 0) {
      return res.status(404).json({
        message: "folder not found",
      });
    }

    await db.execute(
      `
      UPDATE folders
      SET
      name=?
      WHERE
      id=?
      AND
      user_id=?
      `,
      [name.trim(), req.params.id, req.user.id],
    );

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

exports.deleteFolder = async (req, res) => {
  try {
    const [folders] = await db.execute(
      `
      SELECT id
      FROM folders
      WHERE
      id=?
      AND
      user_id=?
      `,
      [req.params.id, req.user.id],
    );

    if (folders.length === 0) {
      return res.status(404).json({
        message: "folder not found",
      });
    }

    await deleteFolderRecursive(req.params.id, req.user.id);

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

exports.getFolderContents = async (req, res) => {
  try {
    const folderId = req.params.id;

    const [folders] = await db.execute(
      `
      SELECT *
      FROM folders
      WHERE
      user_id=?
      AND
      parent_id=?
      `,
      [req.user.id, folderId],
    );

    const [notes] = await db.execute(
      `
      SELECT
      notes.*,
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
      notes.user_id=?
      AND
      notes.folder_id=?
      `,
      [req.user.id, req.user.id, folderId],
    );

    for (const note of notes) {
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

    return res.json({
      folders,
      notes,
    });
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};

exports.getRootContents = async (req, res) => {
  try {
    const [folders] = await db.execute(
      `
      SELECT *
      FROM folders
      WHERE
      user_id=?
      AND
      parent_id IS NULL
      `,
      [req.user.id],
    );

    const [notes] = await db.execute(
      `
      SELECT
      notes.*,
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
      notes.user_id=?
      AND
      notes.folder_id IS NULL
      `,
      [req.user.id, req.user.id],
    );

    for (const note of notes) {
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

    return res.json({
      folders,
      notes,
    });
  } catch (error) {
    console.log(error);

    return res.status(500).json({
      message: error.message,
    });
  }
};
