local example = require 'lib.std'

example.setup = function(session)
    session.workerlist.custom = 
    {
        {
            id = 'spaceandclean',
            func=example.worker.spacendclean},
        {
            id = 'example',
            func = function(session,cmd)
                print("sucesso3")
            end
        }
    }
    session.workerlist.custom2 = 
    {
        {
            id = 'spaceandclean',
            func=example.worker.spacendclean},
        {
            id = 'examples',
            func = function(session,cmd)
                print("sucesso2")
            end
        }
    }
end

return example