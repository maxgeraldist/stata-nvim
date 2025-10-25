import log from './log';
import { initialize } from './methods/initialize';
import { completion } from './methods/textDocument/completion';
import { didChange } from './methods/textDocument/didChange';

interface Message {
	jsonrpc: string;
};

export interface NotificationMessage extends Message {
	method: string;
	params?: unknown[] | object;
};

export interface RequestMessage extends NotificationMessage {
	id: number | string;
};


type RequestMethod = (
	message: RequestMessage
) => ReturnType<typeof initialize> | ReturnType<typeof completion>;

type NotificationMethod = (message: NotificationMessage) => void;


const methodLookup: Record<string, RequestMethod | NotificationMethod> = {
	initialize,
	"textDocument/completion": completion,
	"textDocument/didChange": didChange,
};

const respond = (id: RequestMessage['id'], result:object | null) => {
	const msg = JSON.stringify({id, result});
	const messageLength = Buffer.byteLength(msg, "utf-8");
	const header = `Content-Length: ${messageLength}\r\n\r\n`;
	// log.write(header+msg);
	process.stdout.write(header+msg);
};

/*
	the chunk passed into the following function contains a json payload as well 
	as a content header and an additional \n character. By initializizing buf
	outside of the function, the json object can be parsed from the additional
	characters using a regex 
*/
process.stdin.setEncoding("utf8");

let buf = Buffer.alloc(0);

process.stdin.on("data", (chunk) => {
  buf = Buffer.concat([buf, Buffer.from(chunk, "utf8")]);

  while (true) {
    const str = buf.toString("utf8");

    // find header end (\r\n\r\n or \n\n)
    const headerMatch = str.match(/Content-Length: (\d+)\s*\r?\n\r?\n/);
    if (!headerMatch) break;

    const contentLength = parseInt(headerMatch[1], 10);
    const headerEndIndex = headerMatch.index + headerMatch[0].length;
    const totalLength = Buffer.byteLength(str.slice(0, headerEndIndex), "utf8");

    if (buf.length < totalLength + contentLength) break; // wait for more data

    const jsonBytes = buf.subarray(totalLength, totalLength + contentLength);
    const rawMsg = jsonBytes.toString("utf8");

    try {
      const message = JSON.parse(rawMsg);
      const method = message.method && methodLookup[message.method];
      if (method) {
        const result = method(message);
        if (result !== undefined) respond(message.id, result);
      }
    } catch (err) {
      log.write({
        error: "JSON parse failed",
        rawLength: rawMsg.length,
        err: err.message,
        snippetEnd: rawMsg.slice(-20)
      });
    }

    // remove processed bytes
    buf = buf.subarray(totalLength + contentLength);
  }
});

