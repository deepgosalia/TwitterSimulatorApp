// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket"

let channel = socket.channel('room:lobby', {}); // connect to chat "room"

//let channel_reg = socket.channel('register:lobby', {});

/*******************************Mentions********************************** */

let ulm = document.getElementById('men-list');
channel.on('men', function (payload) { // listen to the 'shout' event
  let li = document.createElement("li"); // create new list item
  li.classList.add("list-group-item");
  li.innerHTML = payload.message; // set li contents
  ulm.appendChild(li);
});

let men_btn = document.getElementById("btn_men");
men_btn.addEventListener("click",function (){
  channel.push('men', { // send the message to the server on "shout" channel
      message: "mentions"
    });
    
});



/*******************************Query********************************** */


let ulq = document.getElementById('search-list');
channel.on('query', function (payload) { // listen to the 'shout' event
  let li = document.createElement("li"); // create new list item
  li.classList.add("list-group-item");
  li.innerHTML = payload.message; // set li contents
  ulq.appendChild(li);
});


let query_btn = document.getElementById("btn_query");
let msgq = document.getElementById('query');
query_btn.addEventListener("click",function (){
  ulq.innerHTML = ""
  channel.push('query', { // send the message to the server on "shout" channel
      message: msgq.value
    });
    
});


/*******************************Register********************************** */
channel.on('register', function (payload) { // listen to the 'shout' event
document.getElementById("msg_sign").innerHTML = payload.message;

});


let reg_btn = document.getElementById("btn_register");


reg_btn.addEventListener("click",function (){
  let usr = document.getElementById('usr');
let pswd = document.getElementById('pswd');
  console.log(usr.value)
  channel.push('register', { // send the message to the server on "shout" channel
      usr: usr.value,     // get value of "name" of person sending the message
      pswd: pswd.value    // get message text (value) from msg input field.
      
    });
    usr.value = '';
    pswd.value = '';
});

/*******************************Subscribe********************************** */

let ul = document.getElementById('sub-list');
channel.on('subscribe', function (payload) { // listen to the 'shout' event
  if(payload.message !== "notfound"){
    let li = document.createElement("li");
    li.innerHTML = payload.message; // set li contents
    li.classList.add("list-group-item");
    ul.appendChild(li);
  }else{
    alert("No such user")
  }
  
});


let sub_btn = document.getElementById("btn_sub");
let msg = document.getElementById('subscribe');
sub_btn.addEventListener("click",function (){
  channel.push('subscribe', { // send the message to the server on "shout" channel
      message: msg.value
    });
    
});



/*******************************Tweet********************************** */

let uls = document.getElementById('msg-list');
channel.on('tweet', function (payload) { // listen to the 'shout' event
  let li = document.createElement("li"); // create new list
  let button = document.createElement("button");
  button.innerHTML = "Retweet";
  li.innerHTML = payload.message;
  button.setAttribute("id", "btn_retweet");
  //button.onclick = 
  li.classList.add("list-group-item");
  li.appendChild(button);

  uls.appendChild(li);
});



let ret_btn = document.getElementById("btn_retweet");
  ret_btn.addEventListener("click",function(){
    console.log("hererer")
    alert("hello");
  });

let tweet_btn = document.getElementById("btn_tweet");
let msgs = document.getElementById('tweet');
tweet_btn.addEventListener("click",function (){
  channel.push('tweet', { // send the message to the server on "shout" channel
      message: msgs.value
    });
    
});


/*******************************Logout********************************** */


channel.on('logout', function (payload) { // listen to the 'shout' event
if (payload.message === "User Logged out"){
  var elm = document.getElementById("login_div");
  var dash = document.getElementById("dashboard");
  if (elm.style.display === "none") {
    elm.style.display = "block";
    dash.style.display = "none"
  } else {
    elm.style.display = "none";
    dash.style.display = "block"
  }
  document.getElementById("sub-list").innerHTML = "";
  document.getElementById("msg-list").innerHTML = "";
  ulq.innerHTML = ""
  ul.innerHTML = ""
  ulm.innerHTML = ""
  uls.innerHTML = ""
}else{
  document.getElementById("msg_sign").innerHTML = payload.message;

}
});


let logout_btn = document.getElementById("btn_logout");

logout_btn.addEventListener("click",function (){
  console.log(usr.value)
  channel.push('logout', { // send the message to the server on "shout" channel
      msg: "logout"
      
    });
    
});



/*******************************Login********************************** */


channel.on('login', function (payload) { // listen to the 'shout' event
if (payload.message === "User Logged in"){
  var elm = document.getElementById("login_div");
  var dash = document.getElementById("dashboard");
  if (elm.style.display === "none") {
    elm.style.display = "block";
    dash.style.display = "none"
  } else {
    elm.style.display = "none";
    dash.style.display = "block"
  }
  
}else{
  document.getElementById("msg_sign").innerHTML = payload.message;

}
});


let log_btn = document.getElementById("btn_login");

log_btn.addEventListener("click",function (){
  let usr = document.getElementById('usr');
let pswd = document.getElementById('pswd');
  console.log(usr.value)
  channel.push('login', { // send the message to the server on "shout" channel
      usr: usr.value,     // get value of "name" of person sending the message
      pswd: pswd.value    // get message text (value) from msg input field.
      
    });
    usr.value = '';
    pswd.value = '';
});


/*******************************Sample********************************** */

// channel.on('shout', function (payload) { // listen to the 'shout' event
//   let li = document.createElement("li"); // create new list item DOM element
//   let name = payload.name || 'guest';    // get name from payload or set default
//   li.innerHTML = '<b>' + name + '</b>: ' + payload.message; // set li contents
//   ul.appendChild(li);                    // append to list
// });
//channel.leave()
//channel.join(); // join the channel.


//let ul = document.getElementById('msg-list');        // list of messages.
//let name = document.getElementById('name');          // name of message sender
//let msg = document.getElementById('msg');            // message input field

// "listen" for the [Enter] keypress event to send a message:
// msg.addEventListener('keypress', function (event) {
//   if (event.keyCode == 13 && msg.value.length > 0) { // don't sent empty msg.
//     channel.push('shout', { // send the message to the server on "shout" channel
//       name: name.value,     // get value of "name" of person sending the message
//       message: msg.value    // get message text (value) from msg input field.
//     });
//     msg.value = '';         // reset the message input field for next message.
//   }
// });
channel.join();