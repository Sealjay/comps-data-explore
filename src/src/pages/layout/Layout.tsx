import { Outlet, NavLink, Link } from "react-router-dom";

import github from "../../assets/github.svg";

import styles from "./Layout.module.css";

const Layout = () => {
    return (
        <div className={styles.layout}>
            <header className={styles.header} role={"banner"}>
                <div className={styles.headerContainer}>
                    <Link to="/" className={styles.headerTitleContainer}>
                        <h3 className={styles.headerTitle}>GPT-4 for Comps</h3>
                    </Link>
                    <nav>
                        <ul className={styles.headerNavList}>
                            <li>Chatting with your corpus</li>
                        </ul>
                    </nav>
                    <h4 className={styles.headerRightText}>Azure OpenAI + Cognitive Search for IO Geeks</h4>
                </div>
            </header>

            <Outlet />
        </div>
    );
};

export default Layout;
