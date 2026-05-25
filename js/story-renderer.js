document.addEventListener('DOMContentLoaded', async function() {
    const loaders = document.querySelectorAll('.story-loader');
    for (const container of loaders) {
        try {
            const res = await fetch(container.dataset.json);
            const data = await res.json();
            let html = '<div class="game-dialogue-wrapper">';
            data.forEach(item => {
                html += `
                    <div class="dialogue-box ${item.type}">
                        <img src="${item.avatar}" class="avatar">
                        <div class="content">
                            <span class="name">${item.character}</span>
                            <p class="text">${item.text}</p>
                        </div>
                    </div>
                `;
            });
            html += '</div>';
            container.innerHTML = html;
        } catch (err) {
            container.innerHTML = '<p>剧情加载失败，请检查 JSON 路径。</p>';
            console.error('Story load error:', err);
        }
    }
});