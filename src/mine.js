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

            // Skip empty lines
            if (line === '') {
                i++;
                continue;
            }

            if (line.startsWith('if') || line.startsWith('while')) {
                // Get the initial condition part
                const conditionPart = line;
                const blockLines = [conditionPart];
                let j = i + 1;
                let openBraces = (line.match(/{/g) || []).length;
                openBraces -= (line.match(/}/g) || []).length;

                // Collect all lines in the block
                while (openBraces > 0 && j < lines.length) {
                    let blockLine = lines[j].trim();
                    if (blockLine !== '') {
                        blockLines.push(blockLine);
                        openBraces += (blockLine.match(/{/g) || []).length;
                        openBraces -= (blockLine.match(/}/g) || []).length;
                    }
                    j++;
                }

                // If this is an if statement
                if (line.startsWith('if')) {
                    this.handle_if(blockLines.join('\n'));
                }
                // If this is a while statement
                else if (line.startsWith('while')) {
                    this.handle_while(blockLines.join('\n'));
                }

                i = j;
            } else {
                this.execute(line);
                i++;
            }
        }
    }

    execute(line) {
        // Skip empty lines
        if (line.trim() === '') {
            return;
        }

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
        // Use a regex that can capture the condition and the code block
        // even if there are multiple lines and nested braces
        const match = line.match(/if\s*\((.*?)\)\s*{([\s\S]*?)}/s);
        if (match) {
            const condition = match[1].trim();
            const codeBlock = match[2].trim();
            if (this.evaluate_expression(condition)) {
                this.parse_block(codeBlock);
            }
        } else {
            console.log(`Syntax error in if statement: ${line}`);
        }
    }

    handle_while(line) {
        // Use a regex that can capture the condition and the code block
        // even if there are multiple lines and nested braces
        const match = line.match(/while\s*\((.*?)\)\s*{([\s\S]*?)}/s);
        if (match) {
            const condition = match[1].trim();
            const codeBlock = match[2].trim();
            while (this.evaluate_expression(condition)) {
                this.parse_block(codeBlock);
            }
        } else {
            console.log(`Syntax error in while statement: ${line}`);
        }
    }

    parse_block(codeBlock) {
        const lines = codeBlock.split('\n');
        for (let line of lines) {
            const trimmedLine = line.trim();
            // Skip empty lines
            if (trimmedLine !== '') {
                this.execute(trimmedLine);
            }
        }
    }

    evaluate_expression(expression) {
        try {
            // Check if it's a string literal (starts and ends with quotes)
            if ((expression.startsWith('"') && expression.endsWith('"')) ||
                (expression.startsWith("'") && expression.endsWith("'"))) {
                return expression.substring(1, expression.length - 1);
            }

            // For other expressions, use Function constructor but with better string handling
            const variableNames = Object.keys(this.variables);
            const variableValues = Object.values(this.variables);

            // Use a safer approach to evaluate expressions
            const modifiedExpression = expression.replace(/(['"])(.*?)\1/g, (match) => {
                return JSON.stringify(match.slice(1, -1));
            });

            const func = new Function(...variableNames, `return ${modifiedExpression};`);
            return func(...variableValues);
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