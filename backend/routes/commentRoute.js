const express = require("express");
const router = express.Router();
const verifyToken = require("../middleware/verifyToken");
const commentController = require("../controllers/commentController");

/**
 * @swagger
 * tags:
 *   name: Comment
 */

/**
 * @swagger
 * /comments:
 *   post:
 *     summary: Create comment
 *
 *     tags:
 *       - Comment
 *
 *     security:
 *       - bearerAuth: []
 *
 *     requestBody:
 *       required: true
 *
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *
 *             required:
 *               - note_id
 *               - comment
 *
 *             properties:
 *
 *               note_id:
 *                 type: integer
 *                 example: 1
 *
 *               comment:
 *                 type: string
 *                 example: Great note!
 *
 *               parent_id:
 *                 type: integer
 *                 nullable: true
 *                 example: 5
 *
 *     responses:
 *
 *       201:
 *         description: Comment created
 *
 *       400:
 *         description: Validation failed
 *
 *       401:
 *         description: Unauthorized
 *
 *       404:
 *         description: Note not found
 *
 *       500:
 *         description: Server error
 */
router.post("/", verifyToken, commentController.createComment);

/**
 * @swagger
 * /comments/{noteId}:
 *   get:
 *     summary: Get comments by note
 *
 *     tags:
 *       - Comment
 *
 *     security:
 *       - bearerAuth: []
 *
 *     parameters:
 *       - in: path
 *         name: noteId
 *         required: true
 *
 *         schema:
 *           type: integer
 *
 *         description: Note ID
 *
 *     responses:
 *
 *       200:
 *         description: Comments retrieved
 *
 *       401:
 *         description: Unauthorized
 *
 *       404:
 *         description: Note not found
 *
 *       500:
 *         description: Server error
 */
router.get("/:noteId", verifyToken, commentController.getComments);

/**
 * @swagger
 * /comments/{id}:
 *   delete:
 *     summary: Delete comment
 *
 *     tags:
 *       - Comment
 *
 *     security:
 *       - bearerAuth: []
 *
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *
 *         schema:
 *           type: integer
 *
 *         description: Comment ID
 *
 *     responses:
 *
 *       200:
 *         description: Comment deleted
 *
 *       401:
 *         description: Unauthorized
 *
 *       404:
 *         description: Comment not found
 *
 *       500:
 *         description: Server error
 */
router.delete("/:id", verifyToken, commentController.deleteComment);

module.exports = router;
