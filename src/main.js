class MineInterpreter {
    constructor() {
        this.variables = {};
    }

    parse(code) {
        const lines = code.split('\n');
        for (let line of lines) {
            this.execute(line.trim());
        }
    }

    execute(line) {
        if (line.startsWith('print')) {
            this.handle_print(line);
        } else if (line.includes('=')) {
            this.handle_assignment(line);
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

    evaluate_expression(expression) {
        try {
            return eval(expression, {}, this.variables);
        } catch (error) {
            console.log(`Evaluation error: ${error}`);
            return null;
        }
    }
}
