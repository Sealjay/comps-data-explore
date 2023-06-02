import { Example } from "./Example";

import styles from "./Example.module.css";

export type ExampleModel = {
    text: string;
    value: string;
};

const EXAMPLES: ExampleModel[] = [
    {
        text: "For a given organizational need (e.g., improving employee engagement), identify the process you would use to build an organizational survey from scratch to assess the targeted area.",
        value: "For a given organizational need (e.g., improving employee engagement), identify the process you would use to build an organizational survey from scratch to assess the targeted area.",
    },
    { text: "Write an outline for an essay on boundaryless and protean careers. Include references used.", value:"Write an outline for an essay on boundaryless and protean careers. Include references used." },
    { text: "What is DEI?", value: "What is DEI?" }
];

interface Props {
    onExampleClicked: (value: string) => void;
}

export const ExampleList = ({ onExampleClicked }: Props) => {
    return (
        <ul className={styles.examplesNavList}>
            {EXAMPLES.map((x, i) => (
                <li key={i}>
                    <Example text={x.text} value={x.value} onClick={onExampleClicked} />
                </li>
            ))}
        </ul>
    );
};
