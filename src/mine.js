const fs = require('fs');

class MineInterpreter {
    constructor() {
        this.variables = {};
    }

    parse(code) {
        const lines = code.split('\n');
        let i = 0;
        while (i < lines.length) {
            let line = lines[i].trim();
            if (line.startsWith('if') || line.startsWith('while')) {
                const blockLines = [];
                let openBraces = 0;
                do {
                    blockLines.push(lines[i].trim());
                    openBraces += (lines[i].match(/{/g) || []).length;
                    openBraces -= (lines[i].match(/}/g) || []).length;
                    i++;
                } while (openBraces > 0 && i < lines.length);
                this.execute(blockLines.join('\n'));
            } else {
                this.execute(line);
                i++;
            }
        }
    }

    execute(line) {
        if (line.startsWith('print')) {
            this.handle_print(line);
        } else if (line.includes('=')) {
            this.handle_assignment(line);
        } else if (line.startsWith('if')) {
            this.handle_if(line);
        } else if (line.startsWith('while')) {
            this.handle_while(line);
        } else {
            console.log(`Syntax error: ${line}`);
        }
    }

    handle_print(line) {
        const match = line.match(/print\s*\((.*)\)/);
        if (match) {
            const expression = match[1].trim();
            const value = this.evaluate_expression(expression);
            console.log(value);
        } else {
            console.log(`Syntax error: ${line}`);
        }
    }

    handle_assignment(line) {
        const parts = line.split('=');
        if (parts.length === 2) {
            const variable = parts[0].trim();
            const expression = parts[1].trim();
            const value = this.evaluate_expression(expression);
            this.variables[variable] = value;
        } else {
            console.log(`Syntax error: ${line}`);
        }
    }

    handle_if(line) {
        const match = line.match(/if\s*\((.*)\)\s*{([\s\S]*)}/);
        if (match) {
            const condition = match[1].trim();
            const codeBlock = match[2].trim();
            if (this.evaluate_expression(condition)) {
                this.parse_block(codeBlock);
            }
        } else {
            console.log(`Syntax error: ${line}`);
        }
    }

    handle_while(line) {
        const match = line.match(/while\s*\((.*)\)\s*{([\s\S]*)}/);
        if (match) {
            const condition = match[1].trim();
            const codeBlock = match[2].trim();
            while (this.evaluate_expression(condition)) {
                this.parse_block(codeBlock);
            }
        } else {
            console.log(`Syntax error: ${line}`);
        }
    }

    parse_block(codeBlock) {
        const lines = codeBlock.split('\n');
        for (let line of lines) {
            this.execute(line.trim());
        }
    }

    evaluate_expression(expression) {
        try {
            const func = new Function(...Object.keys(this.variables), `return ${expression};`);
            return func(...Object.values(this.variables));
        } catch (error) {
            console.log(`Evaluation error: ${error}`);
            return null;
        }
    }
}

// Command line interface
if (require.main === module) {
    const args = process.argv.slice(2);
    if (args.length !== 1) {
        console.log('Usage: node mine.js <file-name>');
        process.exit(1);
    }

    const fileName = args[0];
    fs.readFile(fileName, 'utf8', (err, data) => {
        if (err) {
            console.error(`Error reading file: ${err.message}`);
            process.exit(1);
        }

        const interpreter = new MineInterpreter();
        interpreter.parse(data);
    });
}
