defmodule TwitterApp do
  def start() do
    [num_usr, num_msg] = [100, 10]


    # we need to ETS table for storing info
    # # to store user and its process id <usr,pid>
    # :ets.new(:usrProcessTable,[:set,:public,:named_table])
    # # to store the user and its subscriber <usr, List<usr>>
    # :ets.new(:subTable,[:set,:public,:named_table])
    # # store the the usr and its msg <usr, List<msg>>
    # :ets.new(:msgTable,[:set,:public,:named_table])

    # :ets.new(:eid,[:set,:public,:named_table])
    # :ets.new(:pending, [:set,:public,:named_table])
    # :ets.new(:hashtag_table, [:set, :public, :named_table])
    # :ets.new(:mentions_table, [:set, :public, :named_table])

    # start twitter engine
    # engines task is to distribute so it wont maintain any state
    {:ok,eng_id}=Engine.start_link([])
    :ets.insert(:eid, {"eid",eng_id})






    #generate subscribers randomly

    # number of tweet

    TwitterApp.registerAllUser(num_usr,num_msg)
    TwitterApp.generateRandSub(num_usr)
    TwitterApp.send_message(num_usr,num_msg)


    stime = System.os_time(:millisecond)
    :ets.insert(:eid, {"stime",stime})

    #Twitter.send_message(num_usr,num_msg)

  #   Process.sleep(100)
  #  # Twitter.query_mentions(3)
  #   # User.logout(3)
  #   # User.logout(4)
  #   # User.logout(5)
  #   Process.sleep(100)
  #   # User.login(3,3)



    #loop()
  end



  def generateRandSub(num_usr) do
    Enum.each(1..num_usr, fn(x)->

      Enum.each(1..5, fn(y)->
        sub = Enum.random(1..num_usr)
        sub = Integer.to_string(sub)
        sub=:crypto.hash(:sha,sub) |> Base.encode16 |> String.slice(0..5) |> String.to_integer(16)

        usr = Integer.to_string(x)
        usr=:crypto.hash(:sha, usr) |> Base.encode16 |> String.slice(0..5) |> String.to_integer(16)

        if :ets.member(:usrProcessTable, sub) do
          result=Engine.subscribe(usr,sub)
          #push(socket, "subscribe", %{message: temp})
        else
          #push(socket, "subscribe", %{message: "notfound"})
        end

      end)
    end)
   :true
  end


  def generateRandSub(num_usr) do
    Enum.each(1..num_usr, fn(x)->


        # we will give each user num_usr/10 followers
        subList=Enum.reduce(1..:rand.uniform(num_usr), [] ,fn(s,acc)->
          rand_sub = :rand.uniform(s)
          cond do
            rand_sub != x ->acc ++ [rand_sub]
            true -> acc ++ []
          end
        end)

        :ets.insert(:subTable,{x, Enum.uniq(subList)})
      end)
      :true
  end

  def genRandSub(num_usr, num_msg) do
    n = num_msg * num_usr * 0.1
    :ets.insert(:eid, {"num",n})
    Enum.each(1..num_usr, fn(x)->
      # we will give each user num_usr/10 followers
      cond do
        div(x,10)==0 -> subList=Enum.reduce(1..trunc(0.7 *num_usr)+1, [] ,fn(s,acc)->

          rand_sub = :rand.uniform(s)
          cond do
            rand_sub != x ->acc ++ [rand_sub]
            true -> acc ++ []
          end
        end)
        :ets.insert(:subTable,{x, Enum.uniq(subList)})

        div(x,5)==0 -> subList=Enum.reduce(1..trunc(0.15 *num_usr)+1, [] ,fn(s,acc)->
          rand_sub = :rand.uniform(s)
          cond do
            rand_sub != x ->acc ++ [rand_sub]
            true -> acc ++ []
          end
        end)
        :ets.insert(:subTable,{x, Enum.uniq(subList)})

        div(x,2)==0 -> subList=Enum.reduce(1..trunc(0.1 *num_usr)+1, [] ,fn(s,acc)->
          rand_sub = :rand.uniform(s)
          cond do
            rand_sub != x ->acc ++ [rand_sub]
            true -> acc ++ []
          end
        end)
        :ets.insert(:subTable,{x, Enum.uniq(subList)})

        true -> subList=Enum.reduce(1..trunc(0.05 *num_usr)+1, [] ,fn(s,acc)->
          rand_sub = :rand.uniform(s)
          cond do
            rand_sub != x ->acc ++ [rand_sub]
            true -> acc ++ []
          end
        end)
        :ets.insert(:subTable,{x, Enum.uniq(subList)})

      end

    end)
  end

def displaySub(n) do
  Enum.each(1..n,fn(x) ->
    [{_,subList}] = :ets.lookup(:subTable, x)
    IO.puts("User #{x} has subscriber:")
    IO.inspect(subList)
  end)
end

def registerAllUser(num_usr,num_msg) do
   # create user process and store its id
   Enum.each(1..num_usr, fn(x)->
    temp = Integer.to_string(x);
    usr=:crypto.hash(:sha, temp) |> Base.encode16 |> String.slice(0..5) |> String.to_integer(16)

    TwitterApp.register(usr,usr)
    :ets.insert(:nameToId, {usr,temp})
  end)
end

  def queryHashTag(hashtag) do
    Engine.getHashTag(hashtag)
  end


  def send_message(num_usr,num_msg) do
    msg_eg = ["Go gators #gators #UFL", "COP5615 is best #DOS", "UFL is in top 10 public universities #UFL #top","Dos is the best practical course offered in ufl #UFL #DOS", "Support for UF football team #gators"]

    Enum.each(1..num_usr, fn(x)->

      sender = Integer.to_string(x)
      sender=:crypto.hash(:sha, sender) |> Base.encode16 |> String.slice(0..5) |> String.to_integer(16)
      cond do
        div(x,10)==0 ->Enum.each(1..trunc(num_msg*0.7)+1, fn(_s)->

          User.send_message(sender,Enum.random(msg_eg))
      end)

      div(x,5)==0 ->Enum.each(1..trunc(num_msg*0.15)+1, fn(_s)->
        User.send_message(sender,Enum.random(msg_eg))
    end)

    div(x,2)==0 ->Enum.each(1..trunc(num_msg*0.1)+1, fn(_s)->
      User.send_message(sender,Enum.random(msg_eg))
  end)
  true->Enum.each(1..trunc(num_msg*0.05)+1, fn(_s)->
    User.send_message(sender,Enum.random(msg_eg))
end)

#User.logOut(:rand.uniform(num_usr))
      end
    end)
    # User.logout(2)
    # User.login(2,2)
    # User.logout(3)
    # User.login(3,2)
    # User.logout(2)
    # User.login(2,2)
    # User.logout(2)
    # User.login(2,2)

    # User.logout(5)
    # User.logout(4)
    # User.login(4,4)
    # User.login(5,5)


    # you can add more input
  end

  def addData(name,msg) do

    :ets.insert(:msgTable,{name, msg})
    #:ets.insert(:msgTable,{"deep","hello"})
  end

  def retData(name) do
    IO.puts("---------------#{:ets.member(:msgTable,name)}  #{name}")
    if :ets.member(:msgTable,name) do
      [{_,msg}] = :ets.lookup(:msgTable,name)
      msg
    else
      "not found"
    end
  end


  def subscribe(usr,sub) do
    #usr wants to subscribe a person(sub)
    #add that person to the sub's subtable
    result=Engine.subscribe(usr,sub)
    #[{_,subList}] = :ets.lookup(:subTable,sub)
    result
  end

  def loop() do
    loop()
  end

  # search for given subscriber
  def query(usr,sub) do
    #IO.puts(sub)
    Engine.queryForSub(usr,sub)
  end

  def retweet(uid) do
    # get all received message
    User.retweet(uid)
  end

  def register(usr_id,usr_pswd) do
    result = Engine.checkUser(usr_id)

    if result==:false do
      User.start_link([usr_id,usr_pswd,1,[],[],0])
      #IO.puts("User#{usr_id} successfully registered")
      :true
    else
      IO.puts("User#{usr_id} already exists")
      :false
    end
  end

  def delete(uid) do
    Engine.deleteUser(uid)
  end

  def display_feed(uid,t) do
    User.getFeed(uid,t)
   # result
  end




  def getSubList(uid) do
    result=Engine.getSubList(uid)
    #IO.inspect(result)
    if result==[] do
      :false
    else
      IO.puts("Subscribers of #{uid} are")
      IO.inspect(result)
      :true
    end

  end

  def query_mentions(uid) do
    Engine.queryMention(uid)
  end
end

#Twitter.start()
