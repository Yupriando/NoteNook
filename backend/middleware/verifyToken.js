const jwt = require("jsonwebtoken");

const verifyToken = (req, res, next) => {
  try {
    const auth = req.headers.authorization;

    if (!auth || !auth.startsWith("Bearer ")) {
      return res.status(401).json({
        message: "token required",
      });
    }

    const token = auth.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    req.user = decoded;

    next();
  } catch (error) {
    return res.status(401).json({
      message: "invalid token",
    });
  }
};

module.exports = verifyToken;
