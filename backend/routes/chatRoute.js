const router = require("express").Router();
const verifyToken = require("../middleware/verifyToken");
const upload = require("../middleware/uploadChat");
const {
  sendMessage,
  getConversation,
  getConversationList,
  getMessages,
  markRead,
  downloadFile,
} = require("../controllers/chatController");

/**
 * @swagger
 * tags:
 *   name: Chat
 */

/**
 * @swagger
 * /chat/send:
 *   post:
 *     summary: Send chat message
 *
 *     tags:
 *       - Chat
 *
 *     security:
 *       - bearerAuth: []
 *
 *     requestBody:
 *       required: true
 *
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *
 *             properties:
 *
 *               receiver_id:
 *                 type: integer
 *                 example: 2
 *
 *               message:
 *                 type: string
 *                 example: Hello mentor
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
 *         description: Message sent
 *
 *       400:
 *         description: Invalid request
 *
 *       401:
 *         description: Unauthorized
 *
 *       404:
 *         description: Receiver not found
 *
 *       500:
 *         description: Server error
 */
router.post("/send", verifyToken, upload.array("files", 10), sendMessage);

/**
 * @swagger
 * /chat:
 *   get:
 *     summary: Get conversation list
 *
 *     tags:
 *       - Chat
 *
 *     security:
 *       - bearerAuth: []
 *
 *     responses:
 *
 *       200:
 *         description: Success
 *
 *       401:
 *         description: Unauthorized
 */
router.get("/", verifyToken, getConversationList);

/**
 * @swagger
 * /chat/download/{filename}:
 *   get:
 *     summary: Download chat file
 *
 *     tags:
 *       - Chat
 *
 *     security:
 *       - bearerAuth: []
 *
 *     parameters:
 *       - in: path
 *         name: filename
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
 *       404:
 *         description: File not found
 *
 *       401:
 *         description: Unauthorized
 */
router.get("/download/:filename", verifyToken, downloadFile);

/**
 * @swagger
 * /chat/{id}:
 *   get:
 *     summary: Get conversation
 *
 *     tags:
 *       - Chat
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
 *     responses:
 *
 *       200:
 *         description: Success
 *
 *       401:
 *         description: Unauthorized
 */
router.get("/:id", verifyToken, getConversation);

/**
 * @swagger
 * /chat/messages/{id}:
 *   get:
 *     summary: Get all messages
 *
 *     tags:
 *       - Chat
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
 *         description: Target user id
 *
 *     responses:
 *
 *       200:
 *         description: Messages retrieved
 *
 *       401:
 *         description: Unauthorized
 */
router.get("/messages/:id", verifyToken, getMessages);

/**
 * @swagger
 * /chat/read/{id}:
 *   put:
 *     summary: Mark conversation as read
 *
 *     tags:
 *       - Chat
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
 *         description: Sender user id
 *
 *     responses:
 *
 *       200:
 *         description: Conversation marked as read
 *
 *       401:
 *         description: Unauthorized
 */
router.put("/read/:id", verifyToken, markRead);

module.exports = router;
