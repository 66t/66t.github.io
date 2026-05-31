(async function initStoryDoc() {
    const streams = document.querySelectorAll('.story-doc-stream');
    for (const container of streams) {
        try {
            const res = await fetch(container.dataset.json);
            const data = await res.json();
            console.log(data)
            let html = '<div class="doc-timeline-wrapper">';

            data.forEach(item => {
                switch (item.cmd) {
                    case 'scene':
                        // 渲染为场景横幅/大纲分割线
                        html += `
                            <div class="doc-node-scene" style="background-image: linear-gradient(rgba(17,17,17,0.7), rgba(17,17,17,0.7)), url(${item.bg})">
                                <div class="scene-tag">SCENE SHIFT</div>
                                <h3 class="scene-title">${item.title}</h3>
                            </div>
                        `;
                        break;

                    case 'show':
                        // 渲染为动作/状态更迭的静态提示
                        html += `
                            <div class="doc-node-meta">
                                <span class="meta-badge">STATUS</span>
                                <span class="meta-text">角色 <strong>${item.character}</strong> 执行动作：${item.action}</span>
                            </div>
                        `;
                        break;

                    case 'say':
                        // 渲染为高对比度的静态对话框
                        html += `
                            <div class="doc-node-dialogue ${item.type || 'normal'}">
                                <div class="doc-avatar-box">
                                    <img src="${item.avatar}" class="doc-avatar" alt="${item.character}">
                                </div>
                                <div class="doc-content-box">
                                    <span class="doc-name">${item.character}</span>
                                    <div class="doc-text">${item.text}</div>
                                </div>
                            </div>
                        `;
                        break;

                    case 'menu':
                        // 渲染为文档中的分支路线归档
                        let optionsHtml = '';
                        item.choices.forEach(choice => {
                            optionsHtml += `<div class="doc-opt-line">➔ ${choice.label} <span class="doc-jump-tag">👉 跳至: ${choice.jump}</span></div>`;
                        });
                        html += `
                            <div class="doc-node-menu">
                                <div class="menu-header">⌥ ${item.title || '剧情分歧归档'}</div>
                                <div class="menu-options-list">${optionsHtml}</div>
                            </div>
                        `;
                        break;
                }
            });

            html += '</div>';
            container.innerHTML = html;
        } catch (err) {
            container.innerHTML = '<div class="doc-error-box"> 文档流矩阵解析失败，请检查 JSON 路径或语法。</div>';
            console.error('Doc stream load error:', err);
        }
    }
})();