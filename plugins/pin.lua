local function action(msg, blocks)
    if blocks[1] == 'pin' then
		if roles.is_admin_cached(msg) then
		    if not blocks[2] then
		        local pin_id = db:get('chat:'..msg.chat.id..':pin')
		        if pin_id then
		            api.sendMessage(msg.chat.id, _('Last message generated by `/pin` ^'), true, pin_id)
		        end
		        return
		    end
			local res, code = api.sendMessage(msg.chat.id, blocks[2]:gsub('$rules', misc.deeplink_constructor(msg.chat.id, 'rules')), true)
			if not res then
				if code == 118 then
				    api.sendMessage(msg.chat.id, _("This text is too long, I can't send it"))
			    else
					api.sendMessage(msg.chat.id, _("This text breaks the markdown.\n"
						.. "More info about a proper use of markdown "
						.. "[here](https://telegram.me/GroupButler_ch/46)."), true)
		    	end
	    	else
	    		db:set('chat:'..msg.chat.id..':pin', res.result.message_id)
	    		api.sendMessage(msg.chat.id, _("You can now pin this message and use `/editpin [new text]` to edit it, without send the new message to pin again"), true, res.result.message_id)
	    	end
    	end
	end
	if blocks[1] == 'editpin' then
		if roles.is_admin_cached(msg) then
			local pin_id = db:get('chat:'..msg.chat.id..':pin')
			if not pin_id then
				api.sendReply(msg, _("You don't have any pinned message sent with `/pin [text to pin]`"), true)
			else
				local res, code = api.editMessageText(msg.chat.id, pin_id, blocks[2]:gsub('$rules', misc.deeplink_constructor(msg.chat.id, 'rules')), nil, true)
				if not res then
					if code == 118 then
				    	api.sendMessage(msg.chat.id, _("This text is too long, I can't send it"))
				    elseif code == 116 then
				    	api.sendMessage(msg.chat.id, _("The preview pinned message I sent *does no longer exist*. I can't edit it"), true)
				    elseif code == 111 then
				    	api.sendMessage(msg.chat.id, _("The text is not modified"), true)
			    	else
						api.sendMessage(msg.chat.id, _("This text breaks the markdown.\n"
							.. "More info about a proper use of markdown "
							.. "[here](https://telegram.me/GroupButler_ch/46)."), true)
		    		end
		    	else
		    		db:set('chat:'..msg.chat.id..':pin', res.result.message_id)
	    			api.sendMessage(msg.chat.id, _("Message edited. Check it here"), nil, pin_id)
	    		end
	    	end
    	end
    end
end

return {
    action = action,
    triggers = {
        config.cmd..'(pin)$',
        config.cmd..'(pin) (.*)$',
		config.cmd..'(editpin) (.*)$',
	}
}