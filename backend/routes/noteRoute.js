const router = require("express").Router();

const verifyToken = require("../middleware/verifyToken");

const upload = require("../middleware/uploadNote");

const {
  createNote,
  getMyNotes,
  updateNote,
  deleteNote,
  getPublicNotes,
  bookmarkNote,
  getBookmarks,
  removeBookmark,
  searchNotes,
  mySearchNotes,
  filterNotes,
  downloadNoteFile,
} = require("../controllers/noteController");

/**
 * @swagger
 * tags:
 *   name: Notes
 */

/**
 * @swagger
 *
 * /notes:
 *   post:
 *     summary: Create note
 *     tags:
 *       - Notes
 *
 *     security:
 *       - bearerAuth: []
 *
 *     requestBody:
 *       required: true
 *
 *       content:
 *         multipart/form-data:
 *
 *           schema:
 *             type: object
 *
 *             required:
 *               - title
 *               - visibility
 *
 *             properties:
 *
 *               folder_id:
 *                 type: integer
 *                 nullable: true
 *                 example: 1
 *
 *               title:
 *                 type: string
 *                 example: string
 *
 *               description:
 *                 type: string
 *                 example: string
 *
 *               visibility:
 *                 type: string
 *                 enum:
 *                   - public
 *                   - private
 *
 *               files:
 *                 type: array
 *
 *                 items:
 *                   type: string
 *                   format: binary
 *
 *     responses:
 *
 *       201:
 *         description: Note created
 *
 *         content:
 *
 *           application/json:
 *
 *             example:
 *
 *               message: created
 *               id: 1
 */
router.post("/", verifyToken, upload.array("files", 10), createNote);

/**
 * @swagger
 *
 * /notes/me:
 *   get:
 *
 *     summary: Get my notes
 *
 *     tags:
 *       - Notes
 *
 *     security:
 *       - bearerAuth: []
 *
 *     responses:
 *
 *       200:
 *         description: Success
 */
router.get("/me", verifyToken, getMyNotes);

/**
 * @swagger
 *
 * /notes/public:
 *   get:
 *
 *     summary: Explore public notes
 *
 *     tags:
 *       - Notes
 *
 *     security:
 *       - bearerAuth: []
 *
 *     responses:
 *
 *       200:
 *         description: Success
 */
router.get("/public", verifyToken, getPublicNotes);

/**
 * @swagger
 *
 * /notes/search:
 *   get:
 *
 *     summary: Search notes
 *
 *     tags:
 *       - Notes
 *
 *     security:
 *       - bearerAuth: []
 *
 *     parameters:
 *
 *       - in: query
 *
 *         name: q
 *
 *         required: true
 *
 *         schema:
 *           type: string
 *
 *         example: flutter
 *
 *     responses:
 *
 *       200:
 *         description: Success
 */
router.get("/search", verifyToken, searchNotes);

/**
 * @swagger
 *
 * /notes/filter:
 *   get:
 *
 *     summary: Filter notes
 *
 *     tags:
 *       - Notes
 *
 *     security:
 *       - bearerAuth: []
 *
 *     parameters:
 *
 *       - in: query
 *
 *         name: visibility
 *
 *         schema:
 *           type: string
 *
 *           enum:
 *             - public
 *             - private
 *
 *       - in: query
 *
 *         name: sort
 *
 *         schema:
 *           type: string
 *
 *           enum:
 *             - newest
 *             - oldest
 *
 *     responses:
 *
 *       200:
 *         description: Success
 */
router.get("/filter", verifyToken, filterNotes);

/**
 * @swagger
 *
 * /notes/bookmark/{id}:
 *   post:
 *
 *     summary: Bookmark note
 *
 *     tags:
 *       - Notes
 *
 *     security:
 *       - bearerAuth: []
 *
 *     parameters:
 *
 *       - in: path
 *
 *         name: id
 *
 *         required: true
 *
 *         schema:
 *           type: integer
 *
 *     responses:
 *
 *       201:
 *         description: Bookmarked
 *
 *       400:
 *         description: Already bookmarked
 */
router.post("/bookmark/:id", verifyToken, bookmarkNote);

/**
 * @swagger
 *
 * /notes/bookmarks:
 *   get:
 *
 *     summary: Get bookmarks
 *
 *     tags:
 *       - Notes
 *
 *     security:
 *       - bearerAuth: []
 *
 *     responses:
 *
 *       200:
 *         description: Success
 */
router.get("/bookmarks", verifyToken, getBookmarks);

/**
 * @swagger
 *
 * /notes/{id}:
 *   put:
 *
 *     summary: Update note
 *
 *     tags:
 *       - Notes
 *
 *     security:
 *       - bearerAuth: []
 *
 *     parameters:
 *
 *       - in: path
 *
 *         name: id
 *
 *         required: true
 *
 *         schema:
 *           type: integer
 *
 *     requestBody:
 *
 *       content:
 *
 *         multipart/form-data:
 *
 *           schema:
 *
 *             type: object
 *
 *             properties:
 *
 *               folder_id:
 *                 type: integer
 *                 nullable: true
 *
 *               title:
 *                 type: string
 *
 *               description:
 *                 type: string
 *
 *               visibility:
 *                 type: string
 *
 *                 enum:
 *                   - public
 *                   - private
 *
 *               files:
 *                 type: array
 *
 *                 items:
 *                   type: string
 *                   format: binary
 *
 *     responses:
 *
 *       200:
 *         description: Updated
 */
router.put("/:id", verifyToken, upload.array("files", 10), updateNote);

/**
 * @swagger
 *
 * /notes/{id}:
 *   delete:
 *
 *     summary: Delete note
 *
 *     tags:
 *       - Notes
 *
 *     security:
 *       - bearerAuth: []
 *
 *     parameters:
 *
 *       - in: path
 *
 *         name: id
 *
 *         required: true
 *
 *         schema:
 *           type: integer
 *
 *     responses:
 *
 *       200:
 *         description: Deleted
 */
router.delete("/:id", verifyToken, deleteNote);

/**
 * @swagger
 *
 * /notes/bookmark/{id}:
 *   delete:
 *
 *     summary: Remove bookmark
 *
 *     tags:
 *       - Notes
 *
 *     security:
 *       - bearerAuth: []
 *
 *     parameters:
 *
 *       - in: path
 *
 *         name: id
 *
 *         required: true
 *
 *         schema:
 *           type: integer
 *
 *     responses:
 *
 *       200:
 *         description: Removed
 */
router.delete("/bookmark/:id", verifyToken, removeBookmark);

/**
 * @swagger
 *
 * /notes/download/{filename}:
 *
 *   get:
 *
 *     summary:
 *       Download note attachment
 *
 *     tags:
 *       - Notes
 *
 *     security:
 *       - bearerAuth: []
 *
 *     parameters:
 *
 *       - in: path
 *
 *         name: filename
 *
 *         required: true
 *
 *         schema:
 *           type: string
 *
 *     responses:
 *
 *       200:
 *         description: File downloaded
 *
 *       401:
 *         description: Unauthorized
 *
 *       404:
 *         description: File not found
 *
 *       500:
 *         description: Server error
 */

router.get("/download/:filename", verifyToken, downloadNoteFile);

/**
 * @swagger
 *
 * /notes/my-search:
 *   get:
 *
 *     summary: Search my notes
 *
 *     tags:
 *       - Notes
 *
 *     security:
 *       - bearerAuth: []
 *
 *     parameters:
 *
 *       - in: query
 *         name: q
 *         required: true
 *
 *         schema:
 *           type: string
 *
 *         example: flutter
 *
 *     responses:
 *
 *       200:
 *         description: Success
 *
 *       401:
 *         description: Unauthorized
 *
 *       500:
 *         description: Server error
 */
router.get("/my-search", verifyToken, mySearchNotes);

module.exports = router;
