# typescript

## tsconfing.base.json

```json
{
  "compilerOptions": {
    "jsx": "react",
    /* Visit https://aka.ms/tsconfig.json to read more about this file */

    /* 项目 */
    // "incremental": true,                              /* 启用增量编译 */
    // "composite": true,                                /* 启用允许TypeScript项目与项目引用一起使用的约束。 */
    // "tsBuildInfoFile": "./",                          /* 指定要安装的文件夹。tsbuildinfo增量编译文件。 */
    // "disableSourceOfProjectReferenceRedirect": true,  /* 在引用复合项目时，禁用首选源文件而不是声明文件 */
    // "disableSolutionSearching": true,                 /* 编辑时从多项目引用检查中选择一个项目。 */
    // "disableReferencedProjectLoad": true,             /* 减少TypeScript自动加载的项目数。 */

    /* 语言与环境 */
    "target": "es2016" /* 为发出的JavaScript设置JavaScript语言版本，并包含兼容的库声明。 */,
    // "lib": [],                                        /* 指定一组描述目标运行时环境的绑定库声明文件。 */
    // "jsx": "preserve",                                /* 指定生成的JSX代码 */
    // "experimentalDecorators": true,                   /* 为TC39 stage 2 draft decorators提供实验支持。 */
    // "emitDecoratorMetadata": true,                    /* 为源文件中的修饰声明发出设计类型元数据。 */
    // "jsxFactory": "",                                 /* 指定针对React JSX emit时使用的JSX工厂函数，例如“React”。createElement'或'h' */
    // "jsxFragmentFactory": "",                         /* 指定针对React JSX emit时用于片段的JSX片段引用，例如“React.Fragment”或“Fragment”。 */
    // "jsxImportSource": "",                            /* 指定使用“jsx: react-jsx*”时用于导入JSX工厂函数的模块说明符` */
    // "reactNamespace": "",                             /* 指定为“createElement”调用的对象。这仅适用于目标为'react`JSX emit的情况。 */
    // "noLib": true,                                    /* 禁用包含任何库文件，包括默认库。d、 ts。 */
    // "useDefineForClassFields": true,                  /* 发出符合ECMAScript标准的类字段。 */

    /* 模块 */
    "module": "commonjs" /* 指定生成的模块代码。 */,
    // "rootDir": "./",                                  /* 在源文件中指定根文件夹。 */
    // "moduleResolution": "node",                       /* 指定TypeScript如何从给定模块说明符中查找文件。 */
    // "baseUrl": "./",                                  /* 指定用于解析非相对模块名称的基目录。 */
    // "paths": {},                                      /* 指定将导入重新映射到其他查找位置的一组条目。 */
    // "rootDirs": [],                                   /* 在解析模块时，允许将多个文件夹视为一个文件夹。 */
    // "typeRoots": [],                                  /* 指定多个类似于“”./node_modules/@types``。*/
    // "types": [],                                      /* 指定要包括但不在源文件中引用的类型包名称。 */
    // "allowUmdGlobalAccess": true,                     /* 允许从模块访问UMD全局。 */
    // "resolveJsonModule": true,                        /* 启用导入。json文件 */
    // "noResolve": true,                                /* 禁止'import's、'require's或`<reference>'s扩展TypeScript应添加到项目中的文件数。 */

    /* JavaScript Support */
    // "allowJs": true,                                  /* 允许JavaScript文件成为程序的一部分。使用“checkJS”选项从这些文件中获取错误。 */
    // "checkJs": true,                                  /* 在已检查类型的JavaScript文件中启用错误报告。*/
    // "maxNodeModuleJsDepth": 1,                        /* 指定用于检查“node_modules”中的JavaScript文件的最大文件夹深度。仅适用于“allowJs”。 */

    /* 发出 */
    // "declaration": true,                              /* 生成d、 ts项目中的TypeScript和JavaScript文件中的文件。 */
    // "declarationMap": true,                           /* 为d.ts文件创建源映射。 */
    // "emitDeclarationOnly": true,                      /* 只输出d.ts文件，不输出JavaScript文件。 */
    // "sourceMap": true,                                /* 为发出的JavaScript文件创建源映射文件。 */
    // "outFile": "./",                                  /* 指定一个文件，将所有输出捆绑到一个JavaScript文件中。如果'declaration'为true，则还指定一个捆绑所有文件的文件。d、 ts输出。 */
    // "outDir": "./",                                   /* 为所有发出的文件指定一个输出文件夹。 */
    // "removeComments": true,                           /* 禁止发布评论 */
    // "noEmit": true,                                   /* 禁用从编译中发送文件。 */
    // "importHelpers": true,                            /* 允许每个项目从tslib导入一次助手函数，而不是每个文件包含它们。 */
    // "importsNotUsedAsValues": "remove",               /* 为仅用于类型的导入指定发射/检查行为 */
    // "downlevelIteration": true,                       /* 为迭代生成更兼容、但冗长且性能更低的JavaScript。 */
    // "sourceRoot": "",                                 /* 指定调试器查找参考源代码的根路径。 */
    // "mapRoot": "",                                    /* 指定调试器应该定位映射文件的位置，而不是生成的位置。 */
    // "inlineSourceMap": true,                          /* 在发出的JavaScript中包含sourcemap文件。 */
    // "inlineSources": true,                            /* 在发出的JavaScript中的sourcemaps中包含源代码。 */
    // "emitBOM": true,                                  /* 在输出文件的开头发出UTF-8字节顺序标记（BOM）。 */
    // "newLine": "crlf",                                /* 设置用于发送文件的换行符。 */
    // "stripInternal": true,                            /* 禁用在JSDoc注释中包含“@internal”的声明。 */
    // "noEmitHelpers": true,                            /* 禁用在编译输出中生成自定义辅助函数，如 `__extends`。 */
    // "noEmitOnError": true,                            /* 如果报告了任何类型检查错误，请禁用发送文件。 */
    // "preserveConstEnums": true,                       /* 禁用删除生成代码中的'const enum'声明。 */
    // "declarationDir": "./",                           /* 为生成的声明文件指定输出目录。 */
    // "preserveValueImports": true,                     /* 在JavaScript输出中保留未使用的导入值，否则将被删除。 */

    /* Interop Constraints */
    // "isolatedModules": true,                          /* 确保在不依赖彼此的情况下安全传输文件导入。 */
    // "allowSyntheticDefaultImports": true,             /* 当模块没有默认导出时，允许“从y导入x”。 */
    "esModuleInterop": true /* 发出额外的JavaScript以简化对导入CommonJS模块的支持。这将启用“allowSyntheticDefaultImports”以实现类型兼容性。 */,
    // "preserveSymlinks": true,                         /* 禁用解析指向其realpath的符号链接。这与节点中的同一标志相关。 */
    "forceConsistentCasingInFileNames": true /* 确保外壳在进口时正确无误。 */,

    /* 类型检查 */
    "strict": true /* 启用所有严格的类型检查选项。 */,
    // "noImplicitAny": true,                            /* 为隐含“any”类型的表达式和声明启用错误报告。。 */
    // "strictNullChecks": true,                         /* 在进行类型检查时，请考虑“null”和“undefined”。 */
    // "strictFunctionTypes": true,                      /* 分配函数时，请检查以确保参数和返回值与子类型兼容。 */
    // "strictBindCallApply": true,                      /* 检查“bind”、“call”和“apply”方法的参数是否与原始函数匹配。 */
    // "strictPropertyInitialization": true,             /* 检查已声明但未在构造函数中设置的类属性。 */
    // "noImplicitThis": true,                           /* 当'this'被指定为'any'类型时，启用错误报告。 */
    // "useUnknownInCatchVariables": true,               /* 将catch子句变量键入“unknown”而不是“any”。 */
    // "alwaysStrict": true,                             /* 确保始终发出“严格使用”。 */
    // "noUnusedLocals": true,                           /* 未读取局部变量时启用错误报告。 */
    // "noUnusedParameters": true,                       /* 未读取函数参数时引发错误 */
    // "exactOptionalPropertyTypes": true,               /* 将可选属性类型解释为书面形式，而不是添加“未定义”。 */
    // "noImplicitReturns": true,                        /* 为未在函数中显式返回的代码路径启用错误报告。 */
    // "noFallthroughCasesInSwitch": true,               /* 为switch语句中的故障案例启用错误报告。 */
    // "noUncheckedIndexedAccess": true,                 /* 在索引签名结果中包含“undefined” */
    // "noImplicitOverride": true,                       /* 确保使用覆盖修饰符标记派生类中的覆盖成员。 */
    // "noPropertyAccessFromIndexSignature": true,       /* 对使用索引类型声明的密钥强制使用索引访问器 */
    // "allowUnusedLabels": true,                        /* 禁用未使用标签的错误报告。 */
    // "allowUnreachableCode": true,                     /* 禁用无法访问代码的错误报告。 */

    /* 完整性 */
    // "skipDefaultLibCheck": true,                      /* 跳过类型检查。d、 ts包含在TypeScript中的文件。 */
    "skipLibCheck": true /* 跳过所有的类型检查。d、 ts文件。 */
  }
}
```
