import { RequestMessage } from "../../server";
import { documents, TextDocumentIdentifier } from "../../documents";
import * as fs from "fs";
import * as path from "path";
import * as os from "os";

function getNvimDataDir(): string {
  // $XDG_DATA_HOME (Linux/macOS)
  if (process.env.XDG_DATA_HOME) {
    return path.join(process.env.XDG_DATA_HOME, "nvim");
  }

  // Windows standard location
  if (process.platform === "win32" && process.env.LOCALAPPDATA) {
    return path.join(process.env.LOCALAPPDATA, "nvim-data");
  }

  // Unix default
  return path.join(os.homedir(), ".local", "share", "nvim");
}

const nvimData = getNvimDataDir();
const filePath = path.join(
  nvimData,
  "lazy",
  "stata-nvim",
  "lsp-server",
  "commands.json"
);

let syntax: string[] = [];
try {
  const jsonStr = fs.readFileSync(filePath, { encoding: "utf8" });
  const jsonObj = JSON.parse(jsonStr);
  syntax = jsonObj.syntax;
} catch (err) {
  console.error("error parsing JSON", err);
}


type CompletionItem = {
	label: string;
};

export interface CompletionList {
	isIncomplete: boolean;
	items: CompletionItem[];
}

interface Position {
	line: number;
	character: number;
};


interface TextDocumentCompletionParams {
	textDocument: TextDocumentIdentifier;
	position:			Position;
};

export interface CompletionParams extends TextDocumentCompletionParams {
	
};

export const completion = (message: RequestMessage): CompletionList | null=> {
	const params = message.params as CompletionParams;
	const  content = documents.get(params.textDocument.uri);
	if (!content) {
		return null;
	}
	const currentLine = content.split("\n")[params.position.line];
	const lineUntilCursor = currentLine.slice(0, params.position.character);
	const currentPrefix = lineUntilCursor.replace(/.*\W(.*?)/, "$1");
	const items = syntax.filter((wd:string) => {
		return wd.startsWith(currentPrefix)
	})
	.slice(0,1000)
	.map((wd:string)=>{
		let formattedWd: string = wd.replace(/_/g, ' ');
		return {label: formattedWd};
	})
	
	return {
		isIncomplete: true, 
		items,
	};
};
