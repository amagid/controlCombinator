--Create a new queue
function createQueue()
    return {
        first = nil,
        last = nil,
        length = 0,
        popCounter = -1
    }
end

--Generate a new element for the queue based on a Combinator
function generateDurationElement(combinator)
    return {
        next = nil,
        combinator = combinator,
        additionalTime = 0
    }
end

--Add an element to the queue
function addElementToQueue(queue, elem)
    if queue.length > 0 then
        --If this combinator needs to terminate its signal before the current first in the list,
        if elem.combinator.output.duration < queue.popCounter then
            --Reduce the additionalTime of the first element in the queue by the new element's duration
            queue.first.additionalTime = queue.popCounter - elem.combinator.output.duration
            --Set additionalTime
            elem.additionalTime = elem.combinator.output.duration
            --set popCounter
            queue.popCounter = elem.additionalTime
        else
            --Subtract current counter
            elem.additionalTime = elem.combinator.output.duration - queue.popCounter
            local element = queue.first
            --While our new element has more additional time than the next element in the queue
            while element.next ~= nil and element.next.additionalTime > elem.additionalTime
                elem.additionalTime = elem.additionalTime - element.next.additionalTime
            end

            --Stick this element in the queue at the proper point
            if element.next ~= nil then
                elem.next = element.next
                element.next = elem
            else
                element.next = elem
                queue.last = elem
            end
        end
    else
        queue.first = elem
        queue.last = elem
        elem.additionalTime = elem.combinator.output.duration
        queue.popCounter = elem.additionalTime
    end
    queue.length = queue.length + 1
end

--Add a combinator to the queue
function addCombinatorToQueue(queue, combinator)
    addElementToQueue(queue, generateDurationElement(combinator))
end

--Remove an element from the queue
function popElementFromQueue(queue)
    --If there are additional elements in the queue
    if queue.length > 0 then
        --Store the first one
        local oldFirst = queue.first
        --Set the second element in the queue as the first
        queue.first = queue.first.next
        --If there was no second element
        if queue.first == nil then
            --Set last to nil to clean references
            queue.last = nil
        else
            --If there was another element, reset the popCounter
            queue.popCounter = queue.first.additionalTime
        end
        --Decrement queue length counter
        queue.length = queue.length - 1
        --Return the combinator
        return oldFirst
    else
        return nil
    end
end

function removeCombinatorFromQueue(queue, combinator)
    --If this combinator is the next one in the list
    if queue.first ~= nil and combinator == queue.first.combinator then
        --If there is another combinator after this one
        if queue.first.next ~= nil then
            --Update that combinator's additional time so that it doesn't pop early
            queue.first.next.additionalTime = queue.first.next.additionalTime + queue.popCounter
        end
        --Remove this element from the queue
        queue.length = queue.length - 1
        return popElementFromQueue(queue)
    end

    --Store the current element
    local element = queue.first
    --Find our combinator in the list
    while element.next ~= nil && element.next.combinator ~= combinator do
        element = element.next
    end
    --If we found our combinator
    if element.next ~= nil then
        --If our combinator is not the last in the list
        if element.next.next ~= nil then
            --Update the additional time of the next element in the list
            element.next.next.additionalTime = element.next.next.additionalTime + element.next.additionalTime
        else
            --If our combinator was the last in the list, set the previous element to be the last in the list
            queue.last = element
        end
        --Remove our combinator from the queue
        element.next = element.next.next
        --Update queue length
        queue.length = queue.length - 1
    end
    return element.next
end

function popCombinatorFromQueue(queue)
    --Pop the element
    local combinator = popElementFromQueue(queue)
    --Unwrap the combinator if possible
    if combinator ~= nil then
        combinator = combinator.combinator
    end
    --Return result
    return combinator
end

function peekAtQueue(queue)
    if queue.length > 0 then
        return queue.first.combinator
    else
        return nil
    end
end