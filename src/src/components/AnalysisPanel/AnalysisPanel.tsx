import { Pivot, PivotItem } from "@fluentui/react";
import DOMPurify from "dompurify";

import styles from "./AnalysisPanel.module.css";

import { SupportingContent } from "../SupportingContent";
import { AskResponse } from "../../api";
import { AnalysisPanelTabs } from "./AnalysisPanelTabs";

interface Props {
    className: string;
    activeTab: AnalysisPanelTabs;
    onActiveTabChanged: (tab: AnalysisPanelTabs) => void;
    activeCitation: string | undefined;
    citationHeight: string;
    answer: AskResponse;
}

const pivotItemDisabledStyle = { disabled: true, style: { color: "grey" } };

export function getFullPdfPath(citationFilePath: string): string {
    // replace /content/ with /contentoriginal/ in citationFilePath
    citationFilePath = citationFilePath.replace("/content/", "/contentoriginal/");
    // remove only the final numbers in the format -0, -11, -111, etc from the filename; it will be in the format file-22ename-11.pdf; return file-22ename.pdf
    citationFilePath = citationFilePath.replace(/-\d+\.pdf$/, ".pdf");
    return citationFilePath;
}

export const AnalysisPanel = ({ answer, activeTab, activeCitation, citationHeight, className, onActiveTabChanged }: Props) => {
    const isDisabledThoughtProcessTab: boolean = !answer.thoughts;
    const isDisabledSupportingContentTab: boolean = !answer.data_points.length;
    const isDisabledCitationTab: boolean = !activeCitation;

    const sanitizedThoughts = DOMPurify.sanitize(answer.thoughts!);
    const fullPDFUrl = activeCitation ? getFullPdfPath(activeCitation) : "";

    return (
        <Pivot
            className={className}
            selectedKey={activeTab}
            onLinkClick={pivotItem => pivotItem && onActiveTabChanged(pivotItem.props.itemKey! as AnalysisPanelTabs)}
        >
            <PivotItem
                itemKey={AnalysisPanelTabs.ThoughtProcessTab}
                headerText="Thought process"
                headerButtonProps={isDisabledThoughtProcessTab ? pivotItemDisabledStyle : undefined}
            >
                <div className={styles.thoughtProcess} dangerouslySetInnerHTML={{ __html: sanitizedThoughts }}></div>
            </PivotItem>
            <PivotItem
                itemKey={AnalysisPanelTabs.SupportingContentTab}
                headerText="Supporting content"
                headerButtonProps={isDisabledSupportingContentTab ? pivotItemDisabledStyle : undefined}
            >
                <SupportingContent supportingContent={answer.data_points} />
            </PivotItem>
            <PivotItem
                itemKey={AnalysisPanelTabs.CitationTab}
                headerText="Citation"
                headerButtonProps={isDisabledCitationTab ? pivotItemDisabledStyle : undefined}
            >
                <a href={fullPDFUrl} target="_blank">
                    Open full PDF
                </a>
                <iframe title="Citation" src={activeCitation} width="100%" height={citationHeight} />
            </PivotItem>
        </Pivot>
    );
};
