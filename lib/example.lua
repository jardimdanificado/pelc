local example = require 'lib.std'

example.setup = function(session)
    session.workerlist.custom = 
    {
        {
            id = 'spaceandclean',
            func=example.worker.spacendclean},
        {
            id = 'example',
            func = function(session)
                print("sucesso")
            end
        }
    }
end

return example