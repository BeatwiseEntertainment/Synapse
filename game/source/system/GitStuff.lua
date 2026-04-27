return function()
    if love.FEATURE_FLAGS.debug then
        local commitID = io.popen("git rev-parse HEAD"):read("*all")
        local branch = io.popen("git rev-parse --abbrev-ref HEAD"):read("*all")
        local status = io.popen("git status --porcelain"):read("*all")

        io.printf("{brightYellow}[CommitID] : " .. commitID .. "{reset}")
        io.printf("{brightMagenta}[Branch] : " .. branch .. "{reset}")
        io.printf("{cyan}[Status]\n" .. (status == "" and "Everything clear :3" or status) .. "{reset}")
    end
end
