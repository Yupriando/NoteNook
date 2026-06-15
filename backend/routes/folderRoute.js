const express = require("express");
const router = express.Router();
const folderController = require("../controllers/folderController");
const verifyToken = require("../middleware/verifyToken");

/**
 * @swagger
 * tags:
 *   name: Folders
 */

/**
 * @swagger
 * /folders:
 *   post:
 *     summary: Create folder
 *
 *     tags:
 *       - Folders
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
 *               - name
 *
 *             properties:
 *
 *               name:
 *                 type: string
 *                 example: Flutter
 *
 *               parent_id:
 *                 type: integer
 *                 nullable: true
 *                 example: 1
 *
 *     responses:
 *
 *       201:
 *         description: Folder created
 *
 *       400:
 *         description: Folder name required
 *
 *       401:
 *         description: Unauthorized
 *
 *       404:
 *         description: Parent folder not found
 *
 *       500:
 *         description: Server error
 */
router.post("/", verifyToken, folderController.createFolder);

/**
 * @swagger
 * /folders:
 *   get:
 *     summary: Get all folders
 *
 *     tags:
 *       - Folders
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
 *
 *       500:
 *         description: Server error
 */
router.get("/", verifyToken, folderController.getFolders);

/**
 * @swagger
 * /folders/root:
 *   get:
 *     summary: Get root folder contents
 *
 *     tags:
 *       - Folders
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
 *
 *       500:
 *         description: Server error
 */
router.get("/root", verifyToken, folderController.getRootContents);

/**
 * @swagger
 * /folders/contents/{id}:
 *   get:
 *     summary: Get folder contents
 *
 *     tags:
 *       - Folders
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
 *         description: Folder ID
 *
 *     responses:
 *
 *       200:
 *         description: Success
 *
 *       401:
 *         description: Unauthorized
 *
 *       404:
 *         description: Folder not found
 *
 *       500:
 *         description: Server error
 */
router.get("/contents/:id", verifyToken, folderController.getFolderContents);

/**
 * @swagger
 * /folders/{id}:
 *   put:
 *     summary: Rename folder
 *
 *     tags:
 *       - Folders
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
 *         description: Folder ID
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
 *               - name
 *
 *             properties:
 *
 *               name:
 *                 type: string
 *                 example: Mobile Development
 *
 *     responses:
 *
 *       200:
 *         description: Folder updated
 *
 *       400:
 *         description: Folder name required
 *
 *       401:
 *         description: Unauthorized
 *
 *       404:
 *         description: Folder not found
 *
 *       500:
 *         description: Server error
 */
router.put("/:id", verifyToken, folderController.renameFolder);

/**
 * @swagger
 * /folders/{id}:
 *   delete:
 *     summary: Delete folder
 *
 *     tags:
 *       - Folders
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
 *         description: Folder ID
 *
 *     responses:
 *
 *       200:
 *         description: Folder deleted
 *
 *       401:
 *         description: Unauthorized
 *
 *       404:
 *         description: Folder not found
 *
 *       500:
 *         description: Server error
 */
router.delete("/:id", verifyToken, folderController.deleteFolder);

module.exports = router;
