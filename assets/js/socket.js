import {Socket} from "phoenix"
// "/socket"に対してSocketを作り、paramsに列挙されている値はuser_socketの
// connect関数でparamsとして受け取れる

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

const createSocket = (topicId) => {
  let channel = socket.channel(`comments:${topicId}`, {})
  channel.join()
    .receive("ok", resp => renderComments(resp.comments)) 
    .receive("error", resp => {console.log("Unable to join", resp);
  });

  // 以後comments:topicId:newというイベントが呼ばれた時にrenderCommentによって
  // 既に表示されているコメント達にコメントが1つ追加される
  channel.on(`comments:${topicId}:new`, renderComment);

  document.querySelector('button').addEventListener('click', () => {
    const content = document.querySelector('textarea').value;

    // add commentというイベントとコメントの中身をサーバーサイドに送る
    channel.push("add comment", { content: content });
  });

  // サーバーサイドから受け取ったcommentsをHTMLにレンダリングする
  function renderComments(comments) {
    const renderedComments = comments.map(comment => {
      return commentTemplate(comment);
    });
  
    document.querySelector('.collection').innerHTML = renderedComments.join('');
  }

  function renderComment(event) {
    const renderedComment = commentTemplate(event.comment);
    document.querySelector('.collection').innerHTML += renderedComment;
  }

  function commentTemplate(comment) {
    let email = 'Anonymus';
    if(comment.user) {
      email = comment.user.email;
    }
    return `
      <li class="collection-item">
        ${comment.content}
        <div class="secondary-content">
          ${email}
        </div>
      </li>
    `;
  }
};

window.createSocket = createSocket;
