import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [react()],
    build: {
        outDir: "dist",
        emptyOutDir: true,
        sourcemap: true
    },
    server: {
        proxy: {
            "/chat": "http://localhost:5000"
        }
    }
});
