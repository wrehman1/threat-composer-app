import express from 'express';
const app = express();
const port = process.env.PORT || 80;
app.get('/health', (req, res) => {
res.json({ status: "ok" });
});
app.listen(port, "0.0.0.0", () => {
console.log(`Health check server is running on port ${port}`);
});