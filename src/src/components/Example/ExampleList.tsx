import { Example } from "./Example";

import styles from "./Example.module.css";

export type ExampleModel = {
    text: string;
    value: string;
};

const EXAMPLES: ExampleModel[] = [
    {
        text: "What are the primary research methods used in organizational psychology?",
        value: "What are the primary research methods used in organizational psychology?"
    },
    {
        text: "Write an outline for an essay on boundaryless and protean careers.",
        value: "Write an outline for an essay on boundaryless and protean careers."
    },
    { text: "What is DEI and how does it differ from ESG?", value: "What is DEI and how does it differ from ESG?" }
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
